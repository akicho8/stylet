# -*- coding: utf-8 -*-
# スーパーマリオ風アクション雛型
require_relative "helper"
require "pathname"

Stylet.production = true

Stylet::Palette[:background] = [107, 140, 255]
Stylet::Palette[:font]       = [255, 255, 255]

module Utils
  include Stylet::Delegators
  extend self

  def draw_vline(x)
    draw_line(vec2[x, srect.min_y], vec2[x, srect.max_y])
  end

  def draw_hline(y)
    draw_line(vec2[srect.min_x, y], vec2[srect.max_x, y])
  end
end

module Sprite
  extend self

  @data ||= {}

  def [](key)
    @data[key]
  end

  def load_file(filename, options = {})
    filename = Pathname(filename).expand_path
    key = filename.basename(".*").to_s
    @data[key] ||= surface_load(filename, options)
  end

  def surface_load(filename, mask: true)
    s = SDL::Surface.load(filename.to_s)
    s.set_color_key(SDL::SRCCOLORKEY, 0) if mask
    s.display_format
  end
end

class ObjectX
  include Stylet::Delegators

  attr_accessor :pos, :speed, :rc

  extend Forwardable
  instance_delegate [:x, :y] => :pos
  instance_delegate [:w, :h] => :rc
end

class BlockBase < ObjectX
  attr_accessor :state, :state

  def initialize(pos: nil)
    @pos = pos
    @rc = rect2[@image.w, @image.h]
    @state = :lock
    @state_counter = 0
  end

  def update
    if @state == :fall_down
      @speed.y += Stylet.context.gravity
      @pos += @speed
      if @pos.y >= (Stylet.context.camera.y + Stylet.context.srect.half_h + @rc.half_h)
        Stylet.context.kill_task self
      end
    end
    if @pos
      if Stylet.context.active_x_range.include?(x)
        screen.put(@image, *(@pos - Stylet.context.camera_offset - @rc.half_wh))
      end
    end
    @state_counter += 1
  end

  def player_panch(player)
  end
end

class SoftBlock < BlockBase
  def initialize(*)
    @image = Sprite.load_file("assets/block.png", :mask => false)
    super
  end

  def player_panch(player)
    @state = :fall_down
    @speed = player.speed.clone
    Stylet::SE["nc30529_stomp"].play
  end
end

class HardBlock < BlockBase
  def initialize(*)
    @image = Sprite.load_file("assets/hard_block.png", :mask => true)
    super
  end
end

class WhiteBlock < BlockBase
  def initialize(*)
    @image = Sprite.load_file("assets/white_block.png", :mask => true)
    super
  end
end

class Coin < ObjectX
  def initialize(pos: nil)
    @pos = pos
    @image = Sprite.load_file("assets/coin_anim_x4.png")
    @rc = rect2[16, 16]
    @anim_count = 4
  end

  def update
    return unless Stylet.context.active_x_range.include?(x)
    return unless Stylet.context.active_y_range.include?(y)
    SDL::Surface.blit(@image, (Stylet.context.frame_counter / 8).modulo(@anim_count) * (@image.w / @anim_count), 0, @rc.w, @rc.h, screen, *(@pos - Stylet.context.camera_offset - @rc.half_wh))
  end
end

class PlayerBase < ObjectX
  include Stylet::Input::Base
  include Stylet::Input::ExtensionButton

  attr_accessor :jump_count

  def initialize(pos: nil)
    super()

    @ground_friction               = 0.90      # 摩擦力(地上でのみ発生)

    @ground_accel                  = 0.20      # 地上での左右加速度
    @air_accel                     = 0.07      # 空中での左右加速度
    @jump_power1                   = 10        # ジャンプ力(1回目)
    @jump_power2                   =  8        # ジャンプ力(2回目以降)
    @jump_cancel                   = 0.6       # ジャンプキャンセル時のジャンプ量減速率
    @jump_max                      = 1         # 2段ジャンプの最大回数
    @speed_max                     = 6.0       # 左右移動最大スピード
    @b_dash                        = 2.5       # Bダッシュ時の加速度倍率
    @speed_truncate                = 0.03      # この値未満になったら左右のスピードを0とする(停止後にゆっくり横移動するのを防ぐため)
    @ground_collisiion_diff        = 16.0      # ブロックにめり込んだYの差分がこの値より小さければブロックの上にのっける
    @downl_collision_wsub          = 6         # 降りるときどれだけゆるくするか(0なら足の先で立てるが1ブロックの隙間に入れない)
    @kabenohutuuuno_hansya         = 0.3       # 左右の壁にめり込んだときのスピードの減速率
    @wall_rebound                  = 0.5       # 壁に衝突したときの反発力(1.0なら減速しない)
    @break_trigger                 = 1.1       # どこまでXスピードに差が出たときのブレーキ音にするか
    @fall_down_func                = false     # ブロックから降りれるか？(ブロックの横当たり判定がある場合は有効にするのが難しい)

    ## ブロックの横判定
    @block_side_collision          = true      # 横の当たり判定を有効にするか？
    @block_side_rebound            = 0.5       # ブロックに横に衝突したときの反発力
    @block_side_ysub               = 16        # ブロックに横に衝突する判定を行うときのY座標の当りをどれだけ緩くするか

    ## ブロックに下からパンチ
    @punch_collistion_h            = 32.0      # ブロックにめり込んだYの差分がこの値より小さければブロックにパンチできる
    @punch_collision_wsub          = 10        # 横の当たり判定をどれだけゆるくするか？
    @punch_rebound_ratio            = 0.2       # ブロックを壊したときの下方向への反発率

    ## 壁蹴り
    @kabeeno_tikasa                = 16        # 壁蹴りが有効な壁との距離
    @wall_kick_speed_x_gteq        = 1.0       # 壁蹴りが可能な横スピード量(n以上で成立)。ある程度強く当たらないといけない。
    @kabekeri_jump                 = 10        # 壁蹴りが成立したときのジャンプ量
    @sankaku_tobi_hatekaeri_tuyosa = 1.0       # 壁蹴りが成立したときの反射量(1.0なら変化なし、1.5で元気よく跳ねかえる)

    @pos                           = pos       # 現在位置
    @pos_before                    = pos       # 前フレームでの位置
    @pos_diff                      = vec2.zero # 直近移動ベクトル(現在位置 - 前回の位置)
    @speed                         = vec2.zero # スピードベクトル
    @before_speed                  = vec2.zero # 前フレームでのスピードベクトル

    @coin_count                    = 0         # 所持コイン数

    ## 作業用
    @jump_cancel_count             = 0         # ジャンプをキャンセルしようとした回数
    @jump_count                    = 0         # 現在のジャンプ回数
    @wall_kick_count               = 0         # 壁蹴りをした回数
    @current_block                 = nil       # ブロックの上に乗っているときの、そのブロックオブジェクト
    @ground_collision              = false     # ブロックまたは床の上にいる状態か？
    @ground_collision_save         = false     # ブロックまたは床の上にいる状態か？(前フレーム)

    @image = Sprite.load_file(@image_filename)
    @rc = rect2[@image.w, @image.h]
  end

  def update
    super if defined? super

    if Stylet.context.state != :edit_mode
      if @ground_collision
        @speed.x *= @ground_friction # ブロックまたは床にいるときは摩擦で徐々に減速する
      end
    end

    if Stylet.context.state != :edit_mode
      key_bit_update_all
      bit_update_by_joy(joys[@joystick_index]) if @joystick_index
      key_counter_update_all
    end

    # ジャンプ
    begin
      if @jump_count == 0
        # 最初のジャンプ
        if @ground_collision
          # ブロックの上にいる場合は、下を押してない状態のみ、ジャンプが反応する
          # ブロックの上にいない場合は、下はチェックしない
          if @fall_down_func
            flag = (@current_block && button.btD.trigger? && axis.down.free?) || (!@current_block && button.btD.trigger?)
          else
            flag = button.btD.trigger?
          end
          if flag
            @speed.y += -@jump_power1
            @jump_count += 1
            jump_process
          end
        end
      elsif @jump_count <= @jump_max
        # 二段ジャンプ
        if button.btD.trigger?
          @speed.y = -@jump_power2
          @jump_count += 1
          jump_process
        end
      end
      unless @ground_collision
        # ジャンプキャンセル(ジャンプ中にボタンを離した)
        if button.btD.free_trigger?
          if @jump_cancel_count == 0
            if @speed.y < 0     # 上昇中なら
              @speed.y *= @jump_cancel
            end
          end
          @jump_cancel_count += 1
        end
      end
    end

    # 左右移動
    begin
      @lr_accel = 0
      if @jump_count == 0
        if axis.right.press?
          @lr_accel = @ground_accel
        elsif axis.left.press?
          @lr_accel = -@ground_accel
        end
        if button.btA.press?
          @lr_accel *= @b_dash
        end
      else
        if axis.right.press?
          @lr_accel = @air_accel
        elsif axis.left.press?
          @lr_accel = -@air_accel
        end
      end
      @speed.x += @lr_accel
    end

    # 降りる(若干違和感あり？)
    if @fall_down_func
      if @current_block
        if axis.down.press? && button.btD.trigger?
          @pos.y = @current_block.pos.y - @current_block.rc.half_h + @ground_collisiion_diff
        end
      end
    end

    # 環境補正
    begin
      if Stylet.context.state != :edit_mode
        @speed.y += Stylet.context.gravity
      end
    end

    # 最終計算
    begin
      if @speed.x.abs < @speed_truncate
        @speed.x = 0
      end

      # if @speed.magnitude > 30.0
      #   @speed = @speed.normalize * 30
      # end

      @speed.x = Stylet::Etc.clamp(@speed.x, (-@speed_max..@speed_max))
      @pos_before = @pos.clone
      @pos += @speed
      @pos_diff = @pos - @pos_before

      if @ground_collision
        if (@before_speed.x - @speed.x).abs >= @break_trigger
          Stylet::SE["se_jump_short"].play
        end
      end
      @before_speed = @speed.clone
    end

    # ここ以降が当り判定
    @ground_collision = false

    active_x_range = Stylet.context.active_x_range
    active_y_range = Stylet.context.active_y_range

    begin
      collistion_blocks = {}

      # ブロックとの当たり判定
      if true
        begin
          @current_block = nil
          if @speed.y > 0           # 落下中(重力があるため静止状態も落下中の状態)のみ判定する。つまりジャンプ中だけ判定が消える。
            active_x_range = Stylet.context.active_x_range
            Stylet.context.blocks.each do |block|
              next if block.pos.nil?
              next unless active_x_range.include?(block.pos.x) # 表示画面外なのでスキップ

              diff_x = (@pos.x - block.pos.x).abs
              if diff_x < (block.rc.half_w + @rc.half_w) - @downl_collision_wsub # 差分が両者の半径の合計より小さければ同じ列にいる
                # Y座標の方は床にどれだけ足がめり込んでいるかで調べる
                # ただし落ちてきているとき speed.y > 0 のみ
                floor_y = block.pos.y - block.rc.half_h # 床
                foot_y = @pos.y + @rc.half_h    # キャラの足の裏
                diff_y = foot_y - floor_y

                # ここ確認
                # Utils.draw_hline(bottom_y - Stylet.context.camera_offset.y)
                # Utils.draw_hline(head_y - Stylet.context.camera_offset.y)

                if 0 < diff_y && diff_y < @ground_collisiion_diff   # ここの block.block_w はうまく調整しないと擦り抜けてしまう
                  @pos.y = floor_y - @rc.half_h
                  @current_block = block
                  stand_on_block_or_ground_process
                  collistion_blocks[block.object_id] = true
                  draw_circle(block.pos - Stylet.context.camera_offset, :radius => block.rc.half_w * 2) unless Stylet.production
                  break
                end
              end
            end
          end
        end
      end

      # ブロックへのパンチ
      if true
        begin
          # @current_block = nil
          if @speed.y < 0           # 落下中(重力があるため静止状態も落下中の状態)のみ判定する。つまりジャンプ中だけ判定が消える。
            Stylet.context.blocks.each do |block|
              next unless active_x_range.include?(block.pos.x) # 表示画面外なのでスキップ

              diff_x = (@pos.x - block.pos.x).abs
              if diff_x < (block.rc.half_w + @rc.half_w) - @punch_collision_wsub # 差分が両者の半径の合計より小さければ同じ列にいる
                # Y座標の方は床にどれだけ足がめり込んでいるかで調べる
                # ただし落ちてきているとき speed.y > 0 のみ
                bottom_y = block.pos.y + block.rc.half_h # 床
                head_y = @pos.y - @rc.half_h    # キャラの頭
                diff_y = bottom_y - head_y
                # Utils.draw_hline(bottom_y - Stylet.context.camera_offset.y)
                # Utils.draw_hline(head_y - Stylet.context.camera_offset.y)
                if 0 <= diff_y && diff_y <= @punch_collistion_h   # ここの block.block_w はうまく調整しないと擦り抜けてしまう
                  # Stylet.context.objects << FallBlock.new(pos: block.pos.clone, speed: @speed.clone)
                  # Stylet.context.blocks.delete(block)
                  # Stylet.context.objects.delete(block)
                  block.player_panch(self)
                  @pos.y = bottom_y + @rc.half_h
                  @speed.y = -@speed.y * @punch_rebound_ratio
                  collistion_blocks[block.object_id] = true
                  draw_circle(block.pos - Stylet.context.camera_offset, :radius => block.rc.half_w * 2) unless Stylet.production
                  break

                  # @current_block = block
                  # stand_on_block_or_ground_process
                end
              end
            end
          end
        end
      end

      # ブロックとの左右の当たり判定
      if @block_side_collision
        Stylet.context.blocks.each do |block|
          next unless active_x_range.include?(block.pos.x)
          next unless active_y_range.include?(block.pos.y)
          next if collistion_blocks[block.object_id]
          # next if block.state == :fall_down

          diff_y = block.pos.y - @pos.y
          len = block.rc.half_h + @rc.half_h
          len_diff = len - diff_y.abs - @block_side_ysub # 当りを弱くしないと横に移動できなくなる
          if len_diff <= 0
            next
          end

          diff_x = block.pos.x - @pos.x
          len = block.rc.half_w + @rc.half_w
          len_diff = len - diff_x.abs
          if len_diff > 0
            if diff_x < 0
              len_diff = -len_diff # 右にいるキャラが左のブロックにめり込んだ場合はキャラを右に補正する
            end
            if @ground_collision_save && block.state == :fall_down # 無駄に難しくなるため、地上にいる場合、落ちてくるブロックとの当たり判定をスルーする
            else
              @speed.x = -@speed.x
              @pos.x += -len_diff
              @speed.x = -@speed.x * @block_side_rebound
              draw_circle(block.pos - Stylet.context.camera_offset, :radius => block.rc.half_w * 2) unless Stylet.production
              break
            end
          end
        end
      end
    end

    # コインとの当たり判定
    begin
      active_x_range = Stylet.context.active_x_range
      Stylet.context.coins.each do |coin|
        next unless active_x_range.include?(coin.pos.x) # 表示画面外なのでスキップ
        next unless active_y_range.include?(coin.pos.y) # 表示画面外なのでスキップ

        diff = @pos - coin.pos
        rdiff = (coin.rc.half_w + @rc.half_w) - diff.magnitude
        if rdiff > 0
          @coin_count += 1
          if @coin_count.modulo(100).zero?
            Stylet::SE["nc2681_1up"].play
          else
            Stylet::SE["nc26792_coin"].play
          end
          Stylet.context.kill_task coin
        end
      end
    end

    # 移動
    begin
      # マリオブラザーズ風の折り返し
      if false
        @pos.x = @pos.x.modulo(srect.w)
      end

      # 地面
      if (@pos.y + @rc.half_h) > Stylet.context.ground_y
        @pos.y = Stylet.context.ground_y - @rc.half_h
        stand_on_block_or_ground_process
      end
    end

    # 三角飛び
    unless @ground_collision
      if @wall_kick_count == 0
        if button.btD.trigger?
          if @jump_count >= 1
            if @speed.x.abs >= @wall_kick_speed_x_gteq
              # 左端
              v = (Stylet.context.virtual_rect.min_x + @image.w / 2) # 左端から半キャラ右に移動した位置(つまり左手が端に接着している状態)
              if (v - @pos.x).abs < @kabeeno_tikasa
                @pos.x = v
                wall_kick_process
              end
              # 右端
              v = (Stylet.context.virtual_rect.max_x - @image.w / 2) # 右端から半キャラ左に移動した位置(つまり右手が端に接着している状態)
              if (v - @pos.x).abs < @kabeeno_tikasa
                @pos.x = v
                wall_kick_process
              end
            end
          end
        end
      end
    end

    # 左右の壁
    if @pos.x < (v = Stylet.context.virtual_rect.min_x + @image.w / 2) || @pos.x > (v = Stylet.context.virtual_rect.max_x - @image.w / 2)
      @pos.x = v
      @speed.x = -@speed.x * @wall_rebound
    end

    # カメラの壁
    # スト2でお互いが目一杯離れているときテレビ画面の端を越えられないのはこの補正があるから
    if Stylet.context.state != :edit_mode
      if @pos.x < (v = (Stylet.context.camera.x - Stylet.context.srect.half_w + rc.half_w)) || @pos.x > (v = (Stylet.context.camera.x + Stylet.context.srect.half_w - rc.half_w))
        @pos.x = v
        @speed.x = -@speed.x * @wall_rebound
      end
    end

    @ground_collision_save = @ground_collision

    draw_texture

    dputs "ground_collision: #{@ground_collision}"
    dputs "speed: #{@speed.round(2)}"
    dputs "pos: #{@pos.round(2)}"
    vputs "#{@name}: #{@coin_count}"
  end

  def draw_texture
    screen.put(@image, *(@pos - Stylet.context.camera_offset - @rc.half_wh))
    # screen.put(@image, *(v - vec2[srect.w, 0]))
    # screen.put(@image, *(v + vec2[srect.w, 0]))
  end

  # ブロックまたは地面の上にいるときの処理
  def stand_on_block_or_ground_process
    @speed.y = 0
    @jump_count = 0
    @ground_collision = true
    @wall_kick_count = 0
  end

  # ジャンプしたときの共通処理
  def jump_process
    @jump_cancel_count = 0
    Stylet::SE["nc27131_jump"].play
  end

  # 壁蹴りしたときの処理
  def wall_kick_process
    @speed.y = -@kabekeri_jump
    @speed.x *= -1
    @speed.x *= @sankaku_tobi_hatekaeri_tuyosa
    @wall_kick_count += 1
    jump_process
  end
end

class Mario < PlayerBase
  include Stylet::Input::StandardKeybordBind
  include Stylet::Input::JoystickBindMethod

  def initialize(*)
    @image_filename = "assets/mario.png"
    @joystick_index = 0
    @name = "1P"
    super
  end

  def update
    super
    if Stylet.production
      @joystick_index = 0
    else
      if Stylet.context.ext_button.btL1.press?
        @joystick_index = 0
      else
        @joystick_index = nil
      end
    end
  end
end

class Luigi < PlayerBase
  include Stylet::Input::HjklKeyboardBind
  include Stylet::Input::JoystickBindMethod

  def initialize(*)
    @image_filename = "assets/luigi.png"
    @joystick_index = 1
    @name = "2P"
    super
    # @jump_max         = 0
    # @jump_power1      = 15
    # @ground_friction  = 0.93
  end

  def update
    super
    if Stylet.production
      @joystick_index = 1
    else
      if Stylet.context.ext_button.btR1.press?
        @joystick_index = 0
      else
        @joystick_index = nil
      end
    end
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  attr_accessor :blocks
  attr_accessor :virtual_rect
  attr_accessor :camera
  attr_accessor :ground_y
  attr_accessor :players
  attr_accessor :coins
  attr_accessor :gravity
  attr_accessor :state, :state_counter

  setup do
    @gravity = 0.4                                  # 重力
    @virtual_rect = rect2[srect.w * 2, srect.h * 2]   # ゲーム内での広さ
    @ground_y = @virtual_rect.h - 32                # 地面

    @wall_scroll_distance_x = 240  # 壁にどれだけ近づいたらスクロールするか
    @wall_scroll_distance_y = 200  # 壁にどれだけ近づいたらスクロールするか
    @camera_speed         = 0.1   # 追従カメラがキャラクタを捉えるまでの速度の倍率(1.0が最大)
    @camera_auto          = false # カメラ自動追従モード(有効にすると画面中央にキャラを表示しようとする)
    @view_play            = 32    # ビューの遊び(ブロックの端が表示されることもあるため若干広めにする)

    # カメラの位置
    @camera = vec2.zero
    @camera.x = srect.center.x
    @camera.y = @virtual_rect.h - srect.center.y
    @camera_target = vec2.zero

    # キャラとの反発
    @rebound_power  = 0.2       # 衝突時の反発力(@speedに加算する倍率)
    @rebound_up_frames = 15     # 反発力増加タイミングのフレーム数
    @rebound_up_powner = 1.0    # 反発力増加分
    @head_jump_mul     = 1.3    # 相手に衝突して跳ねたときのスピードベクトルの倍率(何度も頭上ジャンプすれば高く飛べる)
    @vertical_correction = 0.6  # 垂直補正。キャラと接触したとき12時に方向に補正する割合(1.0なら常に真上にジャンプする)

    # @blocks = [SoftBlock.new(pos: srect.center, rc: Stylet::Rect4.centered_create(16, 16))]

    # @blocks = (n = 8).times.collect do |i|
    #   SoftBlock.new(pos: vec2[rand(@virtual_rect.w), rand(virtual_rect.h)], rc: Stylet::Rect4.centered_create(32, 32))
    # end

    # @blocks = 3.times.flat_map{|j|
    #   (n = 14).times.collect do |i|
    #     SoftBlock.new(pos: vec2[@virtual_rect.w / (n - 1) * (i + (j * 0.5)), @virtual_rect.h - srect.center.y - 100 + j * 120])
    #   end
    # }

    # @blocks = (m = 8).times.flat_map do |j|
    #   (n = 8).times.collect do |i|
    #     SoftBlock.new(pos: vec2[@virtual_rect.w / (n - 1) * (i + (j.modulo(2) * 0.5)), @ground_y - j * 64])
    #   end
    # end

    # # 斜めに配置
    # @blocks = (n = 64).times.collect do |i|
    #   SoftBlock.new(pos: vec2[i * 32, @ground_y - 32 - i * 2])
    # end

    @blocks = []
    @coins = []

    @players = []

    # s = SDL::Surface.load("assets/bg960x480.png")
    # s = SDL::Surface.load("assets/bg_sf2.png")
    # @scene_main_bg = Sprite.surface_load("assets/bg960x640.png", :mask => false)

    # if false
    #   s = SDL::Surface.load("assets/bg800x480.png")
    #   @scene_bg2 = s.display_format
    # end

    Stylet::SE.load("assets/nc26792_coin.ogg", volume: 0.2)
    Stylet::SE.load("assets/nc27131_jump.ogg", volume: 0.2)
    Stylet::SE.load("assets/se_jump_short.ogg", volume: 0.5)
    Stylet::SE.load("assets/nc30529_stomp.ogg", volume: 0.3)
    Stylet::SE.load("assets/nc62985_zelda_secret_open.ogg", volume: 0.5)
    Stylet::SE.load("assets/nc2681_1up.ogg", volume: 0.5)
    Stylet::SE.load("assets/nc6131_ff_cursor.ogg", volume: 0.05)
    Stylet::SE.load("assets/nc45878_buu.ogg", volume: 0.5)

    @cursor.display = false
    SDL::Mouse.hide

    @stage_file = Pathname("stage_infos.rb").expand_path

    @state = :init
    @state_counter = 0
    @stg_index = 0

    @bg_mode = :background
  end

  update do
    if @state == :init
      if @state_counter == 0
        # @players.each{|player|kill_task(player)}
        # task_set Mario.new(pos: vec2[srect.half_w - srect.half_w * 0.1, @ground_y - 32])
        # task_set Luigi.new(pos: vec2[srect.half_w + srect.half_w * 0.1, @ground_y - 32])
        @state = :start
        @state_counter = 0
      end
    end
    if @state == :start
      if @state_counter == 0
        @state = :stg_set
        @state_counter = 0
      end
    end
    if @state == :stg_set
      if @state_counter == 0
        edit_func_stage_reload
        @state = :stg_loop
        @state_counter = 0
      end
    end
    if @state == :stg_loop
      if @coins.empty? || key_down?(SDL::Key::N)
        @state = :stg_clear
        @state_counter = 0
      end
    end
    if @state == :stg_clear
      if @state_counter == 0
        Stylet::SE["nc62985_zelda_secret_open"].play
        @bg_mode = :ff_effect
      end
      if @state_counter == 60 * 2
        @state = :stg_set
        @state_counter = -1
        @stg_index += 1
      end
    end
    if @state == :edit_mode
      if @state_counter == 0
        SDL::Mixer.pause_music

        # @players.each{|player|@objects.delete(player)}
        # @players.clear

        edit_func_init
      end

      vputs "edit_cursor: #{@edit_cursor}"
      vputs "edit_select_object_index: #{@edit_select_object_index}"
      vputs "blocks: #{@blocks.size}"
      vputs "objects: #{@objects.size}"
      vputs "stg_index: #{@stg_index}"

      # カーソル移動
      _edit_cursor = @edit_cursor.clone
      @edit_cursor.x += Stylet.context.axis.right.repeat - Stylet.context.axis.left.repeat
      @edit_cursor.y += Stylet.context.axis.down.repeat - Stylet.context.axis.up.repeat
      @edit_cursor.x = Stylet::Etc.clamp(@edit_cursor.x, @edit_rect.x_range)
      @edit_cursor.y = Stylet::Etc.clamp(@edit_cursor.y, @edit_rect.y_range)
      if @edit_cursor != _edit_cursor
        Stylet::SE[:nc6131_ff_cursor].play
      end

      # カーソル表示
      cursor_left_top = vec2[@edit_cursor.x * @edit_cursor_rc.w, @edit_cursor.y * @edit_cursor_rc.h]
      @edit_cursor_center  = cursor_left_top + @edit_cursor_rc.half_wh
      @camera_target = @edit_cursor_center
      draw_rect(rect4[*(cursor_left_top - camera_offset), *@edit_cursor_rc.wh]) # FIXME: 引数

      # ホールドしているブロックを移動
      if @hold_block
        @hold_block.pos = @edit_cursor_center.clone
      end

      # [L1][L2] ブロックの切り替え
      v = ext_button.btL1.repeat_0or1 - ext_button.btR1.repeat_0or1
      # v = button.btA.repeat_0or1 - button.btD.repeat_0or1
      if v.abs > 0
        Stylet::SE[:nc6131_ff_cursor].play
        @edit_select_object_index += v
        edit_func_block_hold_new
      end

      # △新しいブロックをホールドする
      if button.btB.trigger?
        unless @hold_block
          Stylet::SE[:nc6131_ff_cursor].play
          edit_func_block_hold_new
        end
      end

      # ×ホールドしているブロックを消去する
      if button.btD.trigger?
        if @hold_block
          Stylet::SE[:nc6131_ff_cursor].play
          edit_func_block_kill
        else
          edit_func_kill_object_on_map
        end
      end

      # □ホールドしていなければホールド。ホールドしていればコピーを置く
      if button.btA.trigger?
        if @hold_block
          # 置く
          if @objects.any? {|o|o != @hold_block && o.pos == @hold_block.pos}
            # 置こうとしたけど自分以外のブロックがある場合
            # Stylet::SE["nc45878_buu"].play
            edit_func_kill_hold_object
          end
          Stylet::SE["nc6131_ff_cursor"].play
          edit_func_block_stamp
        else
          if true
            # ホールドする
            if v = @objects.find {|o|o.pos == @edit_cursor_center}
              @hold_block = v
            end
          else
            # 消す
            edit_func_kill_object_on_map
          end
        end
      end

      # ○捕む、離す
      if button.btC.trigger?
        if @hold_block
          edit_func_kill_hold_object
          Stylet::SE["nc6131_ff_cursor"].play
          edit_func_block_stamp
          edit_func_block_kill
        else
          edit_func_block_hold
        end
      end

      if key_down?(SDL::Key::N) || key_down?(SDL::Key::P)
        @stg_index += (key_down?(SDL::Key::N) ? 1 : 0) - (key_down?(SDL::Key::P) ? 1 : 0)
        edit_func_stage_reload
      end

      # if @hold_block
      #   @wall_scroll_distance_x += (Stylet.context.ext_button.btL2.repeat_0or1 - Stylet.context.ext_button.btR2.repeat_0or1)
      # end

      # @camera.x += (Stylet.context.ext_button.btL1.repeat_0or1 - Stylet.context.ext_button.btR1.repeat_0or1)
      # @camera.y += (Stylet.context.ext_button.btL1.repeat_0or1 - Stylet.context.ext_button.btR1.repeat_0or1)

      if key_down?(SDL::Key::S)
        edit_func_stage_save
      end

      if key_down?(SDL::Key::E) || ext_button.btPS.trigger?
        @state = :stg_loop
        @state_counter = 0
        SDL::Mixer.resume_music
      end
    else
      if key_down?(SDL::Key::E) || ext_button.btPS.trigger?
        @state = :edit_mode
        @state_counter = -1
      end
    end

    dputs "#{@state}: #{@state_counter}"

    if key_down?(SDL::Key::R)
      # edit_func_stage_reload
      @state = :stg_set
      @state_counter = -1
      # @stg_index += 1
    end
    @state_counter += 1

    unless Stylet.production
      # @camera.x += (Stylet.context.ext_button.btL1.repeat_0or1 - Stylet.context.ext_button.btR1.repeat_0or1)
      # @camera.y += (Stylet.context.ext_button.btL1.repeat_0or1 - Stylet.context.ext_button.btR1.repeat_0or1)
      # @wall_scroll_distance_x += (Stylet.context.ext_button.btL2.repeat_0or1 - Stylet.context.ext_button.btR2.repeat_0or1)
    end

    # キャラ同士の反発
    begin
      @players.combination(2).each do |p1, p2|
        diff = p1.pos - p2.pos
        next if diff.zero?                                     # まったく同じ位置にいる場合 diff.normalize できないため
        rdiff = (p1.rc.half_w + p2.rc.half_w) - diff.magnitude # めりこみ度 = P1半径+P2の半径 - P1とP2の距離

        unless Stylet.production
          draw_circle(p1.pos - camera_offset, :radius => p1.rc.half_w)
          draw_circle(p2.pos - camera_offset, :radius => p2.rc.half_w)
        end

        if rdiff > 0
          # 反発すると同時にジャンプボタンを押したら反発力4倍
          rebound = proc {|p, sign|
            if true
              # めり込んでない位置まで反発する(さらに反発するなら処理を減らすためにここはスキップしてもいい)
              p.pos += diff.normalize * rdiff * sign / 2
            end
            if true
              # さらに反発(rdiff/2だと力がそのままでおもしろくないので増やした方がいいけど、頭上ジャンプがあるならここはスキップしてもいい)
              p.speed += diff.normalize * rdiff * sign * @rebound_power
            end
            if false
              # ジャンプボタンをタイミングよく押したらもっと跳ねる
              if (1..@rebound_up_frames).include?(p.button.btD.counter)
                p.speed += diff.normalize * rdiff * @rebound_up_powner
                p.jump_process
                # Stylet::SE["coin"].play
              end
            end
            # スピードベクトルが大きいキャラほど大きく動かす場合
            # ・物理的にはおかしいけど初代マリオブラザーズっぽい動きになる)
            # ・これでも頭上で何度もジャンプするのが難しい
            if false
              p.speed = diff.normalize * sign * p.speed.magnitude * @head_jump_mul # だんだんスピードが大きくなる
            end
            # 頭上でジャンプしやすくする(トランポリンぽくなる)
            # なるべく縦方向に補正する
            if true
              p.jump_count = 1 # 頭上ジャンプする毎に二段ジャンプができる
              p.jump_process
              d = diff * sign
              # FIXME: 真上補正は上向きベクトルがあるもののみにした方がいいかも
              a = d.angle + Stylet::Fee.angle_diff(from: d.angle, to: Stylet::Fee.clock(12)) * @vertical_correction
              p.speed = vec2.angle_at(a) * p.speed.magnitude * @head_jump_mul # だんだんスピードが大きくなる
            end
          }
          rebound.call(p1, +1)
          rebound.call(p2, -1)
        end
      end
    end

    vputs "coins: #{@coins.size}"
    Utils.draw_hline(@ground_y - camera_offset.y) unless Stylet.production
    dputs "stg_index: #{@stg_index}"

    dputs "#{@blocks.size}, #{@coins.size}, #{@players.size}, #{@objects.size}"

    update_camera

    scroll_line_check
  end

  def scroll_line_check
    return if Stylet.production
    Utils.draw_vline(srect.min_x + @wall_scroll_distance_x)
    Utils.draw_vline(srect.max_x - @wall_scroll_distance_x)
    Utils.draw_hline(srect.min_y + @wall_scroll_distance_y)
    Utils.draw_hline(srect.max_y - @wall_scroll_distance_y)
  end

  # スクロールの計算
  def update_camera
    # 二人のプレイヤーの真ん中にカメラを合わせる
    if @state == :edit_mode
    else
      if @players.size >= 1
        @camera_target.x = @players.collect(&:x).reduce(0, :+) / @players.size
        @camera_target.y = @players.collect(&:y).reduce(0, :+) / @players.size
      end
    end

    # 中央にキャラクタが来るように自動的にカメラを動かす方法
    if @camera_auto
      d = @camera_target.x - @camera.x # 画面中央とキャラクタの差分
      @camera.x += d * Stylet.context.camera_speed          # 少しずつ差分を減らしていく
    end

    # 強制スクロールする例(左右に揺らす例)
    if false
      movable_width = virtual_rect.w - srect.w # カメラの移動可能な幅
      @camera.x = virtual_rect.half_w + Stylet::Fee.rsin(1.0 / 512 * frame_counter) * movable_width / 2
    end

    # キャラに合わせてスクロールする例
    if true
      # 左
      a = @camera.x - srect.half_w      # スクリーン左端→仮想座標変換
      b = @camera_target.x - a    # 画面左端から距離
      d = @wall_scroll_distance_x - b
      if d > 0
        @camera.x -= d
      end

      # 右
      a = @camera.x + srect.half_w      # スクリーン右端の、仮想画面でのX
      b = a - @camera_target.x         # 画面右端との距離
      d = @wall_scroll_distance_x - b # 画面右端
      if d > 0
        @camera.x += d # めり込んだので右から左にスクロール
      end

      # 下
      a = @camera.y + srect.half_h      # スクリーン右端の、仮想画面でのX
      b = a - @camera_target.y         # 画面右端との距離
      d = @wall_scroll_distance_y - b # 画面右端
      if d > 0
        @camera.y += d # めり込んだので右から左にスクロール
      end

      # 上
      a = @camera.y - srect.half_h      # スクリーン左端→仮想座標変換
      b = @camera_target.y - a    # 画面左端から距離
      d = @wall_scroll_distance_y - b
      if d > 0
        @camera.y -= d
      end
    end

    # スト2のように画面端ではスクロールを止める
    if true
      if @camera.x < srect.half_w
        @camera.x = srect.half_w
      end
      if @camera.x > @virtual_rect.w - srect.half_w
        @camera.x = @virtual_rect.w - srect.half_w
      end
      if @camera.y < srect.half_h
        @camera.y = srect.half_h
      end
      if @camera.y > @virtual_rect.h - srect.half_h
        @camera.y = @virtual_rect.h - srect.half_h
      end
    end

    dputs "camera: #{camera.truncate}"
  end

  def active_x_range
    (@camera.x - srect.half_w - @view_play)...(@camera.x + srect.half_w + @view_play)
  end

  def active_y_range
    (@camera.y - srect.half_h - @view_play)...(@camera.y + srect.half_h + @view_play)
  end

  # カメラの左上が指すゲーム内X
  def camera_offset
    @camera - srect.half_wh
  end

  def background_clear
    # # 多重スクロールする場合は奥にあるものから順に表示していく
    # if @scene_bg2
    #   ox = (@scene_bg2.w - srect.w).to_f / (virtual_rect.w - srect.w) * camera_offset.x
    #   oy = (@scene_bg2.h - srect.h).to_f / (virtual_rect.h - srect.h) * camera_offset.y
    #   SDL::Surface.blit(@scene_bg2, ox, oy, srect.w, srect.h / 2, @screen, 0, 0)
    # end
    #
    if @bg_mode == :background
      draw_rect(srect, :color => :background, :fill => true)
    end
    if @bg_mode == :image
      # カメラと背景画像の関係
      # ゲーム内画面幅1280 : 画像幅960 = カメラ左上座標 : ofs
      # となるので移項すると ofs = 画像幅960 * カメラ左上座標 / ゲーム内画面幅1280
      # offset = @scene_main_bg.w.to_f / virtual_rect.w * camera_offset
      # とすのは間違いで、
      # ゲーム内画面幅1280-640 : 画像幅960-640 = カメラ左上座標 : ofs
      # が正しい。640は画面(カメラ)の幅
      # これで右端が画像の右端と一致する
      ox = (@scene_main_bg.w - srect.w).to_f / (virtual_rect.w - srect.w) * camera_offset.x
      oy = (@scene_main_bg.h - srect.h).to_f / (virtual_rect.h - srect.h) * camera_offset.y
      begin
        SDL::Surface.blit(@scene_main_bg, ox, oy, srect.w, srect.h, @screen, 0, 0)
      rescue RangeError
      end
    end
    if @bg_mode == :ff_effect
      # FF7で敵に遭遇したときの画面エフェクト
      screen.set_alpha(SDL::SRCALPHA, 128)
      SDL::Surface.transform_blit(screen, screen, 1, 1.05, 1.05, *srect.center, *srect.center, SDL::Surface::TRANSFORM_AA | SDL::Surface::TRANSFORM_SAFE)
    end
  end

  def edit_func_init
    @edit_cursor ||= vec2[0, 0]
    @edit_cursor_rc ||= rect2[32, 32]
    @edit_rect ||= rect4[0, 0, virtual_rect.w / @edit_cursor_rc.w, virtual_rect.h / @edit_cursor_rc.h]
    @edit_select_object_index ||= 0

    @select_blocks = [
      SoftBlock.new,
      HardBlock.new,
      WhiteBlock.new,
      Coin.new,
      Mario.new,
      Luigi.new,
    ]
  end

  def edit_func_block_hold
    if v = @objects.find {|o|o.pos == @edit_cursor_center}
      @hold_block = v
    end
  end

  def edit_func_block_kill
    if @hold_block
      kill_task @hold_block
      @hold_block = nil
    end
  end

  def edit_func_block_hold_new
    edit_func_block_kill
    @hold_block = @select_blocks[@edit_select_object_index.modulo(@select_blocks.size)]
    if @hold_block
      @hold_block.pos = @edit_cursor_center.clone # すぐに座標を設定しておくの重要
      task_set @hold_block
    end
  end

  def edit_func_block_stamp
    task_set @hold_block.class.new(pos: @hold_block.pos) # clone だといろいろ共有されてしまう
  end

  def edit_func_kill_hold_object
    if @hold_block
      if obj = @objects.find {|o|o != @hold_block && o.pos == @hold_block.pos}
        kill_task obj
      end
    end
  end

  def edit_func_kill_object_on_map
    unless @hold_block
      if obj = @objects.find {|o|o.pos == @edit_cursor_center}
        kill_task obj
      end
    end
  end

  def edit_func_stage_save
    positions = @objects.group_by(&:class).inject({}) {|hash, (klass, objs)|
      hash.merge(klass.name => objs.collect {|e| e.pos.round.to_a })
    }
    attrs = {
      :world_wh => @virtual_rect.wh.to_a,
      :positions => positions,
    }
    data = {}
    if @stage_file.exist?
      data = eval(@stage_file.read)
    end
    data.update(@stg_index => attrs)
    @stage_file.write(data.inspect)
    puts "output: #{@stage_file}"
  end

  def edit_func_stage_reload
    @blocks.clone.each {|block|kill_task(block)}
    @coins.clone.each {|coin|kill_task(coin)}
    @players.clone.each {|player|kill_task(player)}

    begin
      @stage_file = Pathname("stage_infos.rb").expand_path
      @stage_infos = []
      if @stage_file.exist?
        @stage_infos = eval(@stage_file.read)
      end
      @one_stage = @stage_infos[@stg_index]
      if @one_stage
        @one_stage[:positions].each do |klass, positions|
          positions.each do |pos|
            task_set klass.constantize.new(pos: vec2[*pos])
          end
        end
      end
    end

    if @stg_index == 0
      Stylet::Music.play("assets/musmus_tacos_de_dong.ogg", volume: 0.3)

      (m = 4).times.each do |j|
        (n = 8).times.each do |i|
          if j.even? && (i + j / 2).even?
            klass = HardBlock
          else
            klass = SoftBlock
          end
          v = vec2[16 + @virtual_rect.w / n * (i + (j.next.modulo(2) * 0.5)), @ground_y - 16 - 32 * 2 - 32 * 3 * j]
          task_set klass.new(pos: v)
          task_set Coin.new(pos: v + [0, -32])
        end
      end
      @scene_main_bg = Sprite.surface_load("assets/bg960x640_town.png", :mask => false)
      if false
        # モーションブラー効果
        @scene_main_bg.set_alpha(SDL::SRCALPHA, 64)
        @scene_main_bg = @scene_main_bg.display_format
      end
    end

    if @stg_index == 1
      Stylet::Music.play("assets/musmus_fm_kids.ogg", volume: 0.3)

      (m = 5).times.each do |j|
        (n = 40).times.each do |i|
          task_set Coin.new(pos:  vec2[16 + @virtual_rect.w / n * i, @ground_y - 100 - j * 100 - 32])
          task_set [*[SoftBlock] * 3, HardBlock].sample.new(pos: vec2[16 + @virtual_rect.w / n * i, @ground_y - 100 - j * 100])
        end
      end

      @scene_main_bg = Sprite.surface_load("assets/bg960x640_red_sky.png", :mask => false)
    end

    if @stg_index == 2
      Stylet::Music.play("assets/musmus_nv36.ogg", volume: 0.3)
      @scene_main_bg = Sprite.surface_load("assets/love_live.png", :mask => false)
    end

    if @scene_main_bg
      @bg_mode = :image
    else
      @bg_mode = :background
    end

    begin
      if @coins.empty?
        task_set Coin.new(pos: vec2[32 / 2, @ground_y - 32 / 2])
      end
      if @players.empty?
        task_set Mario.new(pos: vec2[srect.half_w - srect.half_w * 0.1, @ground_y - 32])
        task_set Luigi.new(pos: vec2[srect.half_w + srect.half_w * 0.1, @ground_y - 32])
      end
    end

    if @state == :edit_mode
      SDL::Mixer.pause_music
    end
  end

  # FIXME: 冗長すぎる
  def task_set(v)
    if v.is_a? BlockBase
      @blocks << v
    end
    if v.is_a? PlayerBase
      @players << v
    end
    if v.is_a? Coin
      @coins << v
    end
    @objects << v
  end

  def kill_task(v)
    @objects.delete(v)
    if v.is_a? BlockBase
      @blocks.delete(v)
    end
    if v.is_a? PlayerBase
      @players.delete(v)
    end
    if v.is_a? Coin
      @coins.delete(v)
    end
  end

  run
end
