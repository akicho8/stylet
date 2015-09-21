# -*- coding: utf-8 -*-
require "sdl"
require "pathname"
require "opengl"

SDL.init(SDL::INIT_VIDEO)
SDL::GL.set_attr(SDL::GL_RED_SIZE, 5)
SDL::GL.set_attr(SDL::GL_GREEN_SIZE, 5)
SDL::GL.set_attr(SDL::GL_BLUE_SIZE, 5)
SDL::GL.set_attr(SDL::GL_DEPTH_SIZE, 16)
SDL::GL.set_attr(SDL::GL_DOUBLEBUFFER, 1)
SDL::Screen.open(640, 480, 16, SDL::OPENGL)

GL::Viewport(0, 0, 640, 480)
GL::MatrixMode(GL::PROJECTION)
GL::LoadIdentity()

GL::MatrixMode(GL::MODELVIEW)
GL::LoadIdentity()

GL::Enable(GL::DEPTH_TEST)
GL::DepthFunc(GL::LESS)
GL::ShadeModel(GL::SMOOTH)

loop do
  sleep(0.01)

  while event = SDL::Event2.poll
    case event
    when SDL::Event2::Quit
      exit
    when SDL::Event2::KeyDown
      if event.sym == SDL::Key::ESCAPE || event.sym == SDL::Key::Q
        exit
      end
    end
  end

  GL.ClearColor(0.0, 0.0, 0.2, 0.0) # 背景色の設定(最後の1.0はなんだろう？)
  GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

  GL::Begin(GL::QUADS) # 4つの点があることを宣言

  GL::Color([1.0, 0.0, 0.0]) # 右上
  GL::Vertex([0.75, 0.75, -0.75]) # 右上の点の位置(1.0にすると画面最大になる)
  GL::Color([0.0, 1.0, 0.0]) # 右下
  GL::Vertex([0.75, -0.75, -0.75])
  GL::Color([0.0, 0.0, 1.0]) # 左下
  GL::Vertex([-0.75, -0.75, -0.75])
  GL::Color([0.0, 1.0, 1.0]) # 左上
  GL::Vertex([-0.75, 0.75, -0.75])

  GL::End()           # 点の設定を終了

  GL::MatrixMode(GL::MODELVIEW)
  # GL::Rotate(0.5, 0.5, 0.5, 0.5) # ここを有効にするとなんか知らんが回転する

  SDL::GL.swap_buffers
end
exit

# # a sample with ruby-opengl and Ruby/SDL
# require 'sdl'
# require 'gl'
#
# include Gl
#
# # initialize SDL and opengl
# SDL.init SDL::INIT_VIDEO
# SDL::GL.set_attr SDL::GL_RED_SIZE,5
# SDL::GL.set_attr SDL::GL_GREEN_SIZE,5
# SDL::GL.set_attr SDL::GL_BLUE_SIZE,5
# SDL::GL.set_attr SDL::GL_DEPTH_SIZE,16
# SDL::GL.set_attr SDL::GL_DOUBLEBUFFER,1
# SDL::Screen.open 640,400,16,SDL::OPENGL
#
# glViewport( 0, 0, 640, 400 );
# glMatrixMode( GL_PROJECTION );
# glLoadIdentity( );
#
# glMatrixMode( GL_MODELVIEW );
# glLoadIdentity( );
#
# glEnable(GL_DEPTH_TEST);
#
# glDepthFunc(GL_LESS);
#
# glShadeModel(GL_SMOOTH);
#
# shadedCube=true
#
# color =
#   [[ 1.0,  1.0,  0.0],
#   [ 1.0,  0.0,  0.0],
#   [ 0.0,  0.0,  0.0],
#   [ 0.0,  1.0,  0.0],
#   [ 0.0,  1.0,  1.0],
#   [ 1.0,  1.0,  1.0],
#   [ 1.0,  0.0,  1.0],
#   [ 0.0,  0.0,  1.0]]
#
# cube =
#   [[ 0.5,  0.5, -0.5],
#   [ 0.5, -0.5, -0.5],
#   [-0.5, -0.5, -0.5],
#   [-0.5,  0.5, -0.5],
#   [-0.5,  0.5,  0.5],
#   [ 0.5,  0.5,  0.5],
#   [ 0.5, -0.5,  0.5],
#   [-0.5, -0.5,  0.5]]
#
#
# loop do
#
#   while event = SDL::Event2.poll
#     case event
#     when SDL::Event2::Quit, SDL::Event2::KeyDown
#       exit
#     end
#   end
#
#   glClearColor(0.0, 0.0, 0.0, 1.0);
#   glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
#
#
#   glBegin(GL_QUADS)
#
#   if shadedCube then
#     glColor(color[0]);
#     glVertex(cube[0]);
#     glColor(color[1]);
#     glVertex(cube[1]);
#     glColor(color[2]);
#     glVertex(cube[2]);
#     glColor(color[3]);
#     glVertex(cube[3]);
#
#     glColor(color[3]);
#     glVertex(cube[3]);
#     glColor(color[4]);
#     glVertex(cube[4]);
#     glColor(color[7]);
#     glVertex(cube[7]);
#     glColor(color[2]);
#     glVertex(cube[2]);
#
#     glColor(color[0]);
#     glVertex(cube[0]);
#     glColor(color[5]);
#     glVertex(cube[5]);
#     glColor(color[6]);
#     glVertex(cube[6]);
#     glColor(color[1]);
#     glVertex(cube[1]);
#
#     glColor(color[5]);
#     glVertex(cube[5]);
#     glColor(color[4]);
#     glVertex(cube[4]);
#     glColor(color[7]);
#     glVertex(cube[7]);
#     glColor(color[6]);
#     glVertex(cube[6]);
#
#     glColor(color[5]);
#     glVertex(cube[5]);
#     glColor(color[0]);
#     glVertex(cube[0]);
#     glColor(color[3]);
#     glVertex(cube[3]);
#     glColor(color[4]);
#     glVertex(cube[4]);
#
#     glColor(color[6]);
#     glVertex(cube[6]);
#     glColor(color[1]);
#     glVertex(cube[1]);
#     glColor(color[2]);
#     glVertex(cube[2]);
#     glColor(color[7]);
#     glVertex(cube[7]);
#
#   else
#     glColor(1.0, 0.0, 0.0);
#     glVertex(cube[0]);
#     glVertex(cube[1]);
#     glVertex(cube[2]);
#     glVertex(cube[3]);
#
#     glColor(0.0, 1.0, 0.0);
#     glVertex(cube[3]);
#     glVertex(cube[4]);
#     glVertex(cube[7]);
#     glVertex(cube[2]);
#
#     glColor(0.0, 0.0, 1.0);
#     glVertex(cube[0]);
#     glVertex(cube[5]);
#     glVertex(cube[6]);
#     glVertex(cube[1]);
#
#     glColor(0.0, 1.0, 1.0);
#     glVertex(cube[5]);
#     glVertex(cube[4]);
#     glVertex(cube[7]);
#     glVertex(cube[6]);
#
#     glColor(1.0, 1.0, 0.0);
#     glVertex(cube[5]);
#     glVertex(cube[0]);
#     glVertex(cube[3]);
#     glVertex(cube[4]);
#
#     glColor(1.0, 0.0, 1.0);
#     glVertex(cube[6]);
#     glVertex(cube[1]);
#     glVertex(cube[2]);
#     glVertex(cube[7]);
#
#   end
#
#   glEnd()
#
#   glMatrixMode(GL_MODELVIEW);
#   glRotate(5.0, 1.0, 1.0, 1.0);
#
#   SDL::GL.swap_buffers
#
# end
