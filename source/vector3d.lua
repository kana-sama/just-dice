---@class vector3D
---@overload fun(x: number, y: number, z: number): vector3D
---@operator div(number): vector3D
---@operator add(vector3D): vector3D
---@operator len: number
vector3D = Object:extend()

function vector3D:new(x, y, z)
  self.x = x
  self.y = y
  self.z = z
end

function vector3D.zero()
  return vector3D(0, 0, 0)
end

function vector3D.__len(a)
  return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function vector3D.__add(a, b)
  return vector3D(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vector3D.__sub(a, b)
  return vector3D(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vector3D.__div(a, b)
  return vector3D(a.x / b, a.y / b, a.z / b)
end

---@param other vector3D
---@return boolean
function vector3D:in_same_direction_with(other)
  return #(self + other) > #self
end