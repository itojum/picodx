# --- Context 1: top-level (before Window.loop) ---
$top_level_image  = Image.load("/test/image/image.png")
$top_level_tiles  = Image.load_tiles("/test/image/image.png", 2, 2)

# --- Context 2: class initialize ---
class EnemyA
  def initialize
    @sprite = Image.load("/test/image/image.png")
  end

  def image = @sprite
end

class EnemyB
  def initialize
    @tiles = Image.load_tiles("/test/image/image.png", 2, 2)
  end

  def tiles = @tiles
end

enemy_a = EnemyA.new
enemy_b = EnemyB.new

Window.init("game")

# --- Context 3: inside Window.loop ---
$loop_image = nil
$loop_tiles = nil
$loop_done  = false

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # Context 1 checks
  results << assert_equal(256, $top_level_image.width,  "top-level Image.load: width")
  results << assert_equal(256, $top_level_image.height, "top-level Image.load: height")
  results << assert_equal(true, $top_level_tiles.is_a?(Array), "top-level Image.load_tiles: returns Array")
  results << assert_equal(2,   $top_level_tiles.length,        "top-level Image.load_tiles: 2 rows")
  results << assert_equal(2,   $top_level_tiles[0].length,     "top-level Image.load_tiles: 2 cols in row 0")
  results << assert_equal(128, $top_level_tiles[0][0].width,   "top-level Image.load_tiles: tile width")
  results << assert_equal(128, $top_level_tiles[0][0].height,  "top-level Image.load_tiles: tile height")

  # Context 2 checks
  results << assert_equal(256, enemy_a.image.width,  "initialize Image.load: width")
  results << assert_equal(256, enemy_a.image.height, "initialize Image.load: height")
  results << assert_equal(true, enemy_b.tiles.is_a?(Array),     "initialize Image.load_tiles: returns Array")
  results << assert_equal(2,   enemy_b.tiles.length,            "initialize Image.load_tiles: 2 rows")
  results << assert_equal(128, enemy_b.tiles[1][1].width,       "initialize Image.load_tiles: tile[1][1] width")

  # Context 3: load inside Window.loop (run one iteration then break)
  Window.loop do
    $loop_image = Image.load("/test/image/image.png")
    $loop_tiles = Image.load_tiles("/test/image/image.png", 4, 4)
    break
  end

  results << assert_equal(256, $loop_image.width,  "Window.loop Image.load: width")
  results << assert_equal(256, $loop_image.height, "Window.loop Image.load: height")
  results << assert_equal(4,   $loop_tiles.length,          "Window.loop Image.load_tiles: 4 rows")
  results << assert_equal(64,  $loop_tiles[0][0].width,     "Window.loop Image.load_tiles: tile width 64")

  # Error path check: wrong filename → JS exception message should surface
  error_msg = ""
  begin
    Image.load("/test/image/DOES_NOT_EXIST.png")
  rescue => e
    error_msg = e.message.to_s
  end
  results << (error_msg.length > 0 ?
    "<span class='pass'>PASS</span> bad path raises (#{error_msg})" :
    "<span class='fail'>FAIL</span> bad path did not raise")

  show_results(results)
end
