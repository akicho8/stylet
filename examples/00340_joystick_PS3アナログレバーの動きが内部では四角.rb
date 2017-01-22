# PS3のコントローラーはアナログレバーは見た目は円だけど内部では四角なことの確認
require "./setup"

ANALOG_LEVER_MAX = 32767
ANALOG_LEVER_MAGNITUDE_MAX = Math.sqrt(ANALOG_LEVER_MAX**2 + ANALOG_LEVER_MAX**2)

Stylet.run do
  joys.each do |joy|
    joy.available_analog_levers.each do |key, state|
      v = vec2[*state]
      vputs [joy.name, key, v.magnitude]

      # 取得した値をそのまま使うと斜めのベクトルが強くなりすぎる
      # たんなる方向を示したいときはこれで問題ない
      m = v.magnitude
      rate = m.to_f / ANALOG_LEVER_MAGNITUDE_MAX
      draw_vector(v.normalize * (rate * (srect.height / 2)), :origin => srect.center, :label => m.round)

      # 斜めのベクトルが強くなりすぎないように制限を加えた例
      m = v.magnitude
      if m >= ANALOG_LEVER_MAX
        m = ANALOG_LEVER_MAX
      end
      rate = m.to_f / ANALOG_LEVER_MAX
      draw_vector(v.normalize * (rate * (srect.height / 2)), :origin => srect.center, :label => m.round)
    end
  end

  draw_circle(srect.center, :vertex => 64, :radius => srect.height / 2)
end
