---@class Vector3D
---@overload fun(x: number, y: number, z: number): Vector3D
---@operator div(number): Vector3D
---@operator add(Vector3D): Vector3D
---@operator len: number
Vector3D = Object:extend()

function Vector3D:new(x, y, z)
  self.x = x
  self.y = y
  self.z = z
end

function Vector3D.zero()
  return Vector3D(0, 0, 0)
end

function Vector3D.__len(a)
  return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function Vector3D.__add(a, b)
  return Vector3D(a.x + b.x, a.y + b.y, a.z + b.z)
end

function Vector3D.__sub(a, b)
  return Vector3D(a.x - b.x, a.y - b.y, a.z - b.z)
end

function Vector3D.__div(a, b)
  return Vector3D(a.x / b, a.y / b, a.z / b)
end

---@param other Vector3D
---@return boolean
function Vector3D:in_same_direction_with(other)
  return #(self + other) > #self
end