class Prawn::DocumentHighlight
  attr_accessor :file_path

  def initialize(invoice)
    @invoice = invoice
    @file_path = "public/files/highlight/#{invoice.job_id}.pdf"
    @page_width = 595.28
    @page_height = 841.89
  end

  def generate
    @invoice.key_values.each do |kv|
      kv.geometry_blocks.each{ |b| draw_bounding(b, 'FFFF00') }
    end

    @invoice.table_entries.each do |table|
      table.cell_entries.each{ |cell| draw_bounding(cell.geometry_block, 'FF0000') }
    end

    pdf.render_file @file_path
  end

  def generate_on_page(page)
    @pdf_page = Prawn::Document.new(:page_size => 'A4')
    @file_path = "public/files/highlight/#{@invoice.job_id}_#{page}.pdf"

    @invoice.key_values.at_page(page).each do |kv|
      kv.geometry_blocks.each{ |b| draw_bounding(b, 'FFFF00') }
    end

    @invoice.table_entries.each do |table|
      table.cell_entries.at_page(page).each{ |cell| draw_bounding(cell.geometry_block, 'FF0000') }
    end

    @pdf_page.render_file @file_path
  end

  def remove_file
    FileUtils.remove_entry_secure @file_path
  end

  def draw_bounding(geometry_block, color)
    bounding_box = geometry_block.bounding_box
    top = (1 - bounding_box.top.to_f) * @page_height -36
    left = bounding_box.left.to_f * @page_width -36
    width = bounding_box.width.to_f * @page_width
    height = bounding_box.height.to_f * @page_height 

    @pdf_page.bounding_box([left, top], width: width, height: height) do
      @pdf_page.stroke_color color
      @pdf_page.stroke_bounds
    end
  end
end
