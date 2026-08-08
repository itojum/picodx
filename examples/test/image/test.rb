JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  img = Image.new(32, 24, [255, 0, 0])
  results << assert_equal(32,          img.width,  "Image#width")
  results << assert_equal(24,          img.height, "Image#height")
  results << assert_equal([255, 0, 0], img.color,  "Image#color")
  results << assert_equal([0, 0, 0],   Image.new(8, 8).color, "Image color defaults to black")

  show_results(results)
end
