class Camera
  attr_accessor :pos, :pitch, :yaw, :speed
  def initialize(pos, pitch, yaw)
    @pos = pos
    @pitch = pitch
    @yaw = yaw
    @speed = 0.1
  end

  def front
    VectorMath.normalize({
      x: Math.cos(@yaw * Math::PI / 180) * Math.cos(@pitch * Math::PI / 180),
      y: Math.sin(@pitch * Math::PI / 180),
      z: Math.sin(@yaw * Math::PI / 180) * Math.cos(@pitch * Math::PI / 180)
    })
  end

  def up
    {x: 0, y: 1, z: 0}
  end

  def right
    VectorMath.cross(front, up)
  end
end