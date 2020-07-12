class Ocr::Textract
  attr_accessor :metadata, :blocks, :job_status

  def initialize(file_path=nil, run_in_background=true)
    @file_path = file_path
    @metadata = nil
    @blocks = nil
    @job_status = nil
    @run_in_background = run_in_background
  end

  def find_by(key)
    return unless @blocks
    value = []
    @blocks.each do |b| 
      if b.present? && b[:text]&.include?(key)
        value << b
      end
    end
    value
  end

  def find_by_id(id)
    return unless @blocks
    value = @blocks.detect do |b| 
      b.present? ? b[:id] == id : false
    end
    value
  end

  def find_by_block_type(block_type)
    return unless @blocks
    value = []
    @blocks.each do |b| 
      if b.present? && b[:block_type] == block_type
        value << b
      end
    end
    value
  end

  def find_by_key(key)
    key_value_set_list = find_by_block_type("KEY_VALUE_SET")
    return unless key_value_set_list
    key_block = key_value_set_list.detect do |b|
      b.entity_types[0] == 'KEY' && get_child_relationship(b)&.include?(key)
    end

    if key_block
      get_value_relationship(key_block)
    else
      nil
    end
  end

  def get_child_relationship(block)
    ids = block.relationships&.detect{|r| r.type == "CHILD" }&.ids
    if ids
      ids.map do |id|
        value_block = find_by_id(id)
        value_block[:text] if value_block
      end.reject(&:blank?).join(" ")
    end
  end

  def get_value_relationship(block)
    ids = block.relationships.detect{|r| r.type == "VALUE" }&.ids
    if ids
      ids.map do |id|
        value_block = find_by_id(id)
        get_child_relationship(value_block) if value_block
      end.reject(&:blank?).join(" ")
    end
  end


  # def get_all_child_relationship(block)
  #   block.relationships.each do |r|
  #     next unless r.type != "CHILD"

  #   end
  # end

  def store_all_key_values(invoice)
    key_value_set_list = find_by_block_type("KEY_VALUE_SET")
    return unless key_value_set_list
    key_value_set_list.each do |b|
      #puts b
      next unless b.entity_types[0] == 'KEY'
      kv = KeyValue.new
      kv.invoice_id = invoice.id
      kv.key = get_child_relationship(b)
      store_geometry_bounding(kv, b, 'KEY')
      kv.value = get_value_relationship_and_store_geometry(kv, b)
      kv.save
    end
  end

  def get_value_relationship_and_store_geometry(entry, block)
    ids = block.relationships.detect{|r| r.type == "VALUE" }&.ids
    if ids
      ids.map do |id|
        value_block = find_by_id(id)
        if value_block
          store_geometry_bounding(entry, value_block, 'VALUE')
          get_child_relationship(value_block)
        end
      end.reject(&:blank?).join(" ")
    end
  end

  def store_all_table(invoice)
    table_entry_list = find_by_block_type("TABLE")
    return unless table_entry_list
    table_entry_list.each do |b|
      t = TableEntry.new
      t.invoice_id = invoice.id
      t.save
      store_cells(b, t.id)

      update_table_counts(t)
    end
  end

  def store_cells(table_block, table_entry_id)
    ids = table_block.relationships&.detect{|r| r.type == "CHILD" }&.ids
    if ids
      ids.each do |id|
        cell_block = find_by_id(id)
        puts cell_block
        next unless cell_block
        c = CellEntry.new
        c.table_entry_id = table_entry_id
        c.value = get_child_relationship(cell_block)
        c.row_index = cell_block.row_index
        c.column_index = cell_block.column_index
        c.save

        store_geometry_bounding(c, cell_block, 'CELL')
      end
    end
  end

  def update_table_counts(table)
    last_cell = table.cell_entries.last
    table.update_columns(row_count: last_cell.row_index, column_count: last_cell.column_index)
  end

  def store_geometry_bounding(entry, block, entity_type)
    geo = GeometryBlock.new
    geo.entry = entry
    geo.entity_type = entity_type
    geo.page = block.page
    if geo.save
      bounding = BoundingBox.new
      bounding.geometry_block_id = geo.id
      bounding.top = block.geometry.bounding_box.top
      bounding.left = block.geometry.bounding_box.left
      bounding.width = block.geometry.bounding_box.width
      bounding.height = block.geometry.bounding_box.height 
      bounding.save
    end
  end

  #### Raw text
  def store_all_words(invoice)
    word_entry_list = find_by_block_type("WORD")
    return unless word_entry_list
    word_entry_list.each do |b|
      w = WordEntry.new
      w.invoice_id = invoice.id
      w.value = b[:text]
      w.save
      store_geometry_bounding(w, b, 'WORD')
    end
  end

  ###########################
  # DETECT AND GET RESULT

  def detect_file
    file = File.open(@file_path)
    response = client.detect_document_text({
      document: {
        bytes: file.read,
        # s3_object: {
        #   bucket: "ki-textract-demo-docs",
        #   name: "simple-document-image.jpg",
        #   version: "S3ObjectVersion",
        # },
      },
    })

    @metadata = response.document_metadata
    @blocks = response.blocks
  end

  def detect_file_s3
    #document_name = "mc-orc-demo/invoice/8/medical-declaration-form-interpreter2-LzxIOH.jpg"
    #bucket = "mytest-s3-amazon"
    response = client.detect_document_text({
      document: {
        bytes: "data",  
        s3_object: {
          bucket: s3_bucket,
          name: @file_path
        },
      },
    })

    @metadata = response.document_metadata
    # puts '----------'
    response.blocks.each{|b| puts b[:text] if b.present?}
    @blocks = response.blocks
  end

  def analyze_document
    #document_name = "mc-orc-demo/invoice/7/SVP382128.pdf"
    #bucket = "mytest-s3-amazon"
    response = client.analyze_document({
      document: {
        bytes: "data",
        s3_object: {
          bucket: s3_bucket,
          name: @file_path,
        },
      },
      feature_types: ["TABLES"],
      human_loop_config: {
        human_loop_name: "HumanLoopName",
        flow_definition_arn: "FlowDefinitionArn",
        data_attributes: {
          content_classifiers: ["FreeOfPersonallyIdentifiableInformation"],
        },
      },
    })
  end

  #ASYNC

  def detect_document_text_async
    #document_name = "mc-orc-demo/invoice/7/SVP382128.pdf"
    #bucket = "mytest-s3-amazon"
    token = SecureRandom.hex
    sns_topic_arn = 'arn:aws:sns:ap-southeast-1:084104329414:demo-textract'
    role_arn = 'arn:aws:iam::084104329414:role/SNSSuccessFeedback'

    response = client.start_document_text_detection({
      document_location: {
        s3_object: {
          bucket: s3_bucket,
          name: @file_path
        },
      },
      client_request_token: token,
      job_tag: "DemoTextract",
      notification_channel: {
        sns_topic_arn: sns_topic_arn,
        role_arn: role_arn,
      },
    })

    job_id = response[:job_id]

    #get analyze result
    unless @run_in_background
      count = 0
      until get_document_text(job_id) == true || count > 20
        puts count
        sleep 3
        count += 1
      end
    end

    job_id
  end

  def get_document_text(job_id)
    response = client.get_document_text_detection(job_id: job_id)
    @job_status = response.job_status

    puts @job_status

    if @job_status == "IN_PROGRESS"
      false
    else
      @metadata = response.document_metadata
      response.blocks.each{|b| puts b if b.present?}
      @blocks = response.blocks
      true
    end
  end

  def analyze_document_async
    #document_name = "mc-orc-demo/invoice/9/SVP375078.pdf"
    # document_name = "mc-orc-demo/invoice/7/SVP382128.pdf"
    #bucket = "mytest-s3-amazon"
    token = SecureRandom.hex
    sns_topic_arn = 'arn:aws:sns:ap-southeast-1:084104329414:demo-textract'
    role_arn = 'arn:aws:iam::084104329414:role/SNSSuccessFeedback'

    response = client.start_document_analysis({
      document_location: {
        s3_object: {
          bucket: s3_bucket,
          name: @file_path
        },
      },
      feature_types: ["FORMS", "TABLES"], # required, accepts TABLES, FORMS
      client_request_token: token,
      job_tag: "DemoTextract",
      notification_channel: {
        sns_topic_arn: sns_topic_arn,
        role_arn: role_arn,
      },
    })

    job_id = response[:job_id]

    #get analyze result
    unless @run_in_background
      count = 0
      until get_analyze_document(job_id) == true || count > 20
        puts count
        sleep 3
        count += 1
      end
    end

    job_id
  end

  def get_analyze_document(job_id)
    response = client.get_document_analysis(job_id: job_id)
    @job_status = response.job_status

    puts @job_status

    if @job_status == "IN_PROGRESS"
      false
    else
      puts response
      @metadata = response.document_metadata
      # response.blocks.each{|b| puts b if b.present?}
      @blocks = response.blocks
      true
    end
  end

  private

  def client
    @client ||= Aws::Textract::Client.new
  end

  def client_token
    SecureRandom.hex
  end

  def s3_bucket
    @bucket ||= ENV["S3_BUCKET_NAME"]
  end
end
