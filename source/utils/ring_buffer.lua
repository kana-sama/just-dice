---@class RingBuffer
---@overload fun(size: number, make: fun(): any): RingBuffer
---@operator len: number
RingBuffer = Object:extend()

---@param size integer
function RingBuffer:new(size, make)
  self.size = size
  self.index = 0

  self.buffer = {}
  self.total = nil
  for i = 1, size do
    self.buffer[i] = make()

    if self.total == nil then
      self.total = self.buffer[i]
    else
      self.total += self.buffer[i]
    end
  end
end

---@param value any
function RingBuffer:push(value)
  self.index += 1
  
  if self.index > self.size then
    self.index = 1
  end

  self.total -= self.buffer[self.index]
  self.buffer[self.index] = value
  self.total += self.buffer[self.index]
end

---@generic T
---@param index integer
---@return T
function RingBuffer:nth(index)
  local index = (index + self.index - 1) % self.size + 1
  return self.buffer[index]
end

function RingBuffer:last()
  return self.buffer[self.index]
end

function RingBuffer:prev()
  return self:nth(0)
end

function RingBuffer:average()
  return self.total / self.size
end

function RingBuffer:__len()
  return self.size
end