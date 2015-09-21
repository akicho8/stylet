# -*- coding: utf-8 -*-
require_relative "helper"
require "opengl"

Stylet.config.screen_flags |= SDL::OPENGL

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    SDL::GL.set_attr(SDL::GL_RED_SIZE, 5)
    SDL::GL.set_attr(SDL::GL_GREEN_SIZE, 5)
    SDL::GL.set_attr(SDL::GL_BLUE_SIZE, 5)
    SDL::GL.set_attr(SDL::GL_DEPTH_SIZE, 16)
    SDL::GL.set_attr(SDL::GL_DOUBLEBUFFER, 1)

    GL::Viewport(0, 0, 640, 480)
    GL::MatrixMode(GL::PROJECTION)
    GL::LoadIdentity()

    GL::MatrixMode(GL::MODELVIEW)
    GL::LoadIdentity()

    GL::Enable(GL::DEPTH_TEST)
    GL::DepthFunc(GL::LESS)
    GL::ShadeModel(GL::SMOOTH)
  end

  update do
    GL.ClearColor(0.0, 0.0, 0.2, 0.0) # 背景色の設定(最後の1.0はなんだろう？)
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    GL::Begin(GL::QUADS) # 4つの点があることを宣言

    GL::Color([1.0, 0.0, 0.0])      # 右上
    GL::Vertex([0.75, 0.75, -0.75]) # 右上の点の位置(1.0にすると画面最大になる)
    GL::Color([0.0, 1.0, 0.0])      # 右下
    GL::Vertex([0.75, -0.75, -0.75])
    GL::Color([0.0, 0.0, 1.0])      # 左下
    GL::Vertex([-0.75, -0.75, -0.75])
    GL::Color([0.0, 1.0, 1.0])      # 左上
    GL::Vertex([-0.75, 0.75, -0.75])

    GL::End()           # 点の設定を終了

    GL::MatrixMode(GL::MODELVIEW)
    GL::Rotate(0.5, 0.5, 0.5, 0.5) # ここを有効にするとなんか知らんが回転する

    SDL::GL.swap_buffers
  end

  def background_clear
  end

  run
end
