require 'opengl'
require 'glfw'
require_relative './util/setup_dll'
require_relative 'mesh'
require_relative 'matrix'
require_relative 'obj_loader'
require_relative 'shader'
require_relative 'math'
require_relative 'camera'

include VectorMath

key_callback = GLFW::create_callback(:GLFWkeyfun) do |window_handle, key, scancode, action, mods|
  if key == GLFW::GLFW_KEY_W
    if action == GLFW::GLFW_PRESS
      $move_forward = true
    elsif action == GLFW::GLFW_RELEASE
      $move_forward = false
    end
  end
  if key == GLFW::GLFW_KEY_S
    if action == GLFW::GLFW_PRESS
      $move_back = true
    elsif action == GLFW::GLFW_RELEASE
      $move_back = false
    end
  end
  if key == GLFW::GLFW_KEY_A
    if action == GLFW::GLFW_PRESS
      $move_left = true
    elsif action == GLFW::GLFW_RELEASE
      $move_left = false
    end
  end
  if key == GLFW::GLFW_KEY_D
    if action == GLFW::GLFW_PRESS
      $move_right = true
    elsif action == GLFW::GLFW_RELEASE
      $move_right = false
    end
  end
  if key == GLFW::GLFW_KEY_LEFT_SHIFT
    if action == GLFW::GLFW_PRESS
      $move_down = true
    elsif action == GLFW::GLFW_RELEASE
      $move_down = false
    end
  end
  if key == GLFW::GLFW_KEY_SPACE
    if action == GLFW::GLFW_PRESS
      $move_up = true
    elsif action == GLFW::GLFW_RELEASE
      $move_up = false
    end
  end
  if key == GLFW::GLFW_KEY_R && action == GLFW::GLFW_PRESS
    $camera.pos = {x: 0, y: 0, z: 0}
    $camera.pitch = 0.0
    $camera.yaw = 0.0
  end
  if key == GLFW::GLFW_KEY_I && action == GLFW::GLFW_PRESS
    $light_pos[:y] += 1
  end
  if key == GLFW::GLFW_KEY_K && action == GLFW::GLFW_PRESS
    $light_pos[:y] -= 1
  end

end

cursor_pos_callback = GLFW::create_callback(:GLFWcursorposfun) do |_egg, x, y|
  sensitivity = 0.1
  dx = (x - $last_x_pos) * sensitivity
  dy = (y - $last_y_pos) * sensitivity
  $camera.yaw += dx
  $camera.pitch -= dy
  $last_x_pos = x
  $last_y_pos = y
end

def move_camera
  pos = $camera.pos.clone
  speed = $camera.speed
  $camera.pos = VectorMath.plus(pos, VectorMath.mul($camera.right, num: speed)) if $move_right
  $camera.pos = VectorMath.sub(pos, VectorMath.mul($camera.right, num: speed)) if $move_left
  $camera.pos = VectorMath.plus(pos, VectorMath.mul($camera.up, num: speed)) if $move_up
  $camera.pos = VectorMath.sub(pos, VectorMath.mul($camera.up, num: speed)) if $move_down
  $camera.pos = VectorMath.plus(pos, VectorMath.mul($camera.front, num: speed)) if $move_forward
  $camera.pos = VectorMath.sub(pos, VectorMath.mul($camera.front, num: speed)) if $move_back
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib(SampleUtil.glfw_library_path)
  GLFW.Init()

  GLFW.WindowHint(GLFW::RESIZABLE, GLFW::FALSE)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 2)
  GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)
  GLFW.WindowHint(GLFW::OPENGL_FORWARD_COMPAT, GLFW::TRUE)


  window = GLFW.CreateWindow(1280, 720, "GLFW OpenGL3 Heightmap demo", nil, nil)
  if window == nil
    GLFW.Terminate()
    exit
  end

  GLFW.MakeContextCurrent(window)
  # GLFW.SwapInterval(0)

  GL.load_lib(SampleUtil.gl_library_path)

  GL.Viewport(0, 0, 1280, 720)
  GL.ClearColor(0.0, 0.0, 0.0, 0.0)
  GL.Enable(GL::DEPTH_TEST)

  GLFW.SetKeyCallback(window, key_callback)
  GLFW.SetCursorPosCallback(window, cursor_pos_callback)

  frame = 0
  pm = Matrix4x4.from_perspective(90, (16/9.0), 0.01, 100)
  objects = []
  # objects << Mesh.new([
  #                   0.5,  0.5, 0.5,
  #                   0.5, -0.5, 0.5,
  #                   -0.5, -0.5, 0.5,
  #                   -0.5,  0.5, 0.5,
  #                   0.5,  0.5, -0.5,
  #                   0.5, -0.5, -0.5,
  #                   -0.5, -0.5, -0.5,
  #                   -0.5,  0.5, -0.5,
  #                    ],
  #                 [0, 1, 3,
  #                  1, 2, 3,
  #                  1, 5, 6,
  #                  1, 2, 6,
  #                  5, 6, 7,
  #                  4, 5, 7,
  #                  0, 3, 4,
  #                  3, 4, 7,
  #                  0, 1, 4,
  #                  1, 4, 5,
  #                  2, 7, 3,
  #                  2, 6, 7
  #                ],
  #                {x: -1, y: 0, z: 0})
  # objects << Mesh.new([
  #                   0.5,  0.5, 0.5,
  #                   0.5, -0.5, 0.5,
  #                   -0.5, -0.5, 0.5,
  #                   -0.5,  0.5, 0.5,
  #                   0.5,  0.5, -0.5,
  #                   0.5, -0.5, -0.5,
  #                   -0.5, -0.5, -0.5,
  #                   -0.5,  0.5, -0.5,
  #                    ],
  #                 [0, 1, 3,
  #                  1, 2, 3,
  #                  1, 5, 6,
  #                  1, 2, 6,
  #                  5, 6, 7,
  #                  4, 5, 7,
  #                  0, 3, 4,
  #                  3, 4, 7,
  #                  0, 1, 4,
  #                  1, 4, 5,
  #                  2, 7, 3,
  #                  2, 6, 7
  #                ],
  #                {x: 1, y: 0, z: 0})


  $camera_at = {x: 0, y: 0, z: 0}
  $last_x_pos = 0
  $last_y_pos = 0

  shader = Shader.new("./Shaders/shader_vert.glsl", "./Shaders/shader_frag.glsl")
  # teapot = Mesh.from_file("./Objects/teapot.obj", shader)
  # objects << teapot
  # sun_shader = Shader.new("./Shaders/shader_sun_vert.glsl", "./Shaders/shader_sun_frag.glsl")
  # sun = Mesh.from_file("./Objects/sphere.obj", sun_shader)
  # objects << sun
  cow = Mesh.from_file("./Objects/cow.obj", shader)
  # cow.pos[:z] -= 10
  objects << cow
  $light_pos = {x: 0, y: 0, z: 0}
  camera_pos = {x: 0, y: 0, z: -10}
  camera_yaw = -0.0
  camera_pitch = 0.0
  $camera = Camera.new(camera_pos, camera_pitch, camera_yaw)

  GLFW.SetInputMode(window, GLFW::GLFW_CURSOR, GLFW::GLFW_CURSOR_DISABLED)

  while GLFW.WindowShouldClose(window) == 0
    frame += 1
    # render the next frame
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    $light_pos = $camera.pos.clone
    move_camera

    vm = Matrix4x4.look_at($camera.pos.clone, VectorMath.plus($camera.pos.clone, $camera.front.clone), $camera.up)
    # vm = Matrix4x4.camera($camera_pos.clone, $camera_at.clone)
    objects.each do |object|
      object.draw(pm, vm)
    end

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end