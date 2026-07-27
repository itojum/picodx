Window.init("game")
Window.bgcolor = [20, 20, 40]

bx = 300
by = 200
vx = 4
vy = 3
ball = Image.new(24, 24, [255, 80, 80])
bounces = 0

Window.loop do
  bx += vx
  by += vy

  if bx <= 0 || bx + ball.width >= Window.width
    vx = -vx
    bounces += 1
  end
  if by <= 0 || by + ball.height >= Window.height
    vy = -vy
    bounces += 1
  end

  Window.draw(bx, by, ball)
  Window.draw_font(8, 20, "Bounces: #{bounces}", [255, 255, 255])

  if Input.key_down?(K_UP)
    vy -= 1 if vy > -12
  end
  if Input.key_down?(K_DOWN)
    vy += 1 if vy < 12
  end
  if Input.key_down?(K_LEFT)
    vx -= 1 if vx > -12
  end
  if Input.key_down?(K_RIGHT)
    vx += 1 if vx < 12
  end
end
