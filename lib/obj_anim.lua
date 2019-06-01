
__world__ = {}
objAnim = {}
objAnim.__index = objAnim

function objAnim.new(sprites)
    local self = setmetatable({}, objAnim)
    
    -- main attributes
    self.x = 0
    self.y = 0
    self.w = 0
    self.h = 0
    self.width = 0
    self.height = 0
    self.direction = 1
    self.rotation = 0
    self.scaleW = 1
    self.scaleH = 1  

    self.isPlatformOrPhysic = "platform"

    --PLATFORM PLATFORM ATTRIBUTES
    self.speed = 0
    self.gravity = 0
    self.mass = 0
    self.massInc = 0
    self.state = "stand"
    self.lastX = 0
    self.lastY = 0
    self.indexWorld = 0 

    --PHYSICS attributes
    self.phySpeed = 0
    self.physic = {}

    -- controler attributes
    self.activeInputs = false
    self.up = "w"
    self.down = "s"
    self.left = "a"
    self.right = "d"
    self.jump = "space"

    -- animation attributes
    self.index_animation = 0
    self.current_animation = nil
    self.list_images_sheets = sprites
    self.list_animations_data = {}

    return self
end

function objAnim.createAnim(self, sprite_id, rows, cols, last_sprite, frameRate, isLoop, static)
    local image = love.graphics.newImage(self.list_images_sheets[sprite_id])
    local sprites_arr = {}
    sprites_arr[0] = image
    local w, h = image:getDimensions()
    local qX = w / cols
    local qY = h / rows
    local x = 0
    local y = 0
    local count = 1
    while (y < h) do
        while(x < w and count <= last_sprite) do
            local spt = love.graphics.newQuad(x, y, qX, qY, image:getDimensions())
            table.insert(sprites_arr, spt)
            count = count + 1
            x = x + qX
        end
        x = 0
        y = y + qY
    end

    local animation_data = {
        frames = {},
        frameRate = nil,
        last_spt = nil,
        isLoop = nil,
        currentFrame = 1,
        endLoop = false
    }    

    animation_data.frames = sprites_arr
    animation_data.frameRate = frameRate
    animation_data.last_spt = last_sprite
    animation_data.isLoop = isLoop
    animation_data.endLoop = static
    table.insert(self.list_animations_data, animation_data)
    self.width = qX
    self.height = qY
    self.w = qX
    self.h = qY
end

function objAnim.update(self, dt)

    if (self.current_animation.endLoop == false) then
        self.current_animation.currentFrame = self.current_animation.currentFrame + (self.current_animation.frameRate * dt)
    else
        self.current_animation.currentFrame = 1
    end

    
    if (self.isPlatformOrPhysic == "physic") then

        physicsInputs(self)
        self.x = self.physic.body:getX()
        self.y = self.physic.body:getY()

    elseif (self.isPlatformOrPhysic == "platform") then

        checkCollision(self)
    
        platformInputs(self, dt)
        
        --gravity
        if(self.massInc < self.mass) then
            self.massInc = self.massInc + dt * self.gravity * self.mass
        end
        self.y = self.y + dt * self.gravity * self.massInc

        updateState(self)        
    end

end

function objAnim.anim(self)

    if(self.current_animation.currentFrame > self.current_animation.last_spt + 1) then
        self.current_animation.currentFrame = 1
        if(self.current_animation.isLoop == false)then
            self.current_animation.endLoop = true
        end 
    end

    local frame = math.floor(self.current_animation.currentFrame)

    if (self.isPlatformOrPhysic == "physic") then
        love.graphics.draw(self.current_animation.frames[0], self.current_animation.frames[frame], 
        self.physic.body:getX(), self.physic.body:getY(), math.rad(0), self.scaleW * self.direction, self.scaleH, self.width / 2, self.height / 2)
    else
        love.graphics.draw(self.current_animation.frames[0], self.current_animation.frames[frame], 
        self.x, self.y, math.rad(0), self.scaleW * self.direction, self.scaleH, self.width / 2, self.height / 2)
    end
    

end

function objAnim.setCurrentAnimation(self, index)
    self.index_animation = index
    self.current_animation = self.list_animations_data[index]
end

function objAnim.setPhysics(self, world, mass, phySpeed)
    self.physic.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physic.body:setMass(mass)
    self.physic.shape = love.physics.newRectangleShape(self.width / 2, self.height / 2)
    self.physic.fixture = love.physics.newFixture(self.physic.body, self.physic.shape)
    self.physic.fixture:setRestitution(0)
    self.physic.fixture:getUserData("Character")
    self.phySpeed = phySpeed
end

function objAnim.setPosX(self, x)
    if (self.physic.body) then
        self.physic.body:setX(self.physic.body:getX() + (self.width / 2))
    else
        self.x = x + (self.width / 2)
        self.lastX = self.x
    end
end

function objAnim.setPosY(self, y)
    if (self.physic.body) then
        self.physic.body:setY(self.physic.body:getY() - (self.height / 2))
    else
        self.y = y - (self.height / 2)
        self.lastY = self.y
    end    
end

function objAnim.getPosX(self)
    return self.x - (self.width / 2)
end

function objAnim.getPosY(self)
    return self.y + (self.height / 2)
end

function objAnim.setPosXY(self, x, y)
    if (self.physic.body) then
        self.physic.body:setX(self.physic.body:getX() + (self.width / 2))
        self.physic.body:setY(self.physic.body:getY() - (self.height / 2))
    else    
        self.x = x + (self.width / 2)
        self.y = y - (self.height / 2)
        self.lastX = self.x
        self.lastY = self.y
    end
end

function objAnim.getPosXY(self)
    return {self.x - (self.width / 2), self.y + (self.height / 2)}
end

function objAnim.setDirection(self, direction)
    self.direction = direction
end

function objAnim.getDirection(self)
    return self.direction
end

function objAnim.setRotation(self, rotation)
    self.rotation = rotation
end

function objAnim.getRotation(self)
    return self.rotation
end

function objAnim.setScaleW(self, scaleW)
    self.scaleW = scaleW
    self.width = scaleW * self.w
end

function objAnim.getScaleW(self)
    return self.scaleW
end

function objAnim.setScaleH(self, scaleH)
    self.scaleH = scaleH
    self.height = scaleH * self.h
end

function objAnim.setScaleWH(self, scaleW, scaleH)
    self.scaleW = scaleW
    self.width = scaleW * self.w
    self.scaleH = scaleH
    self.height = scaleH * self.h
end

function objAnim.getScaleH(self)
    return self.scaleH
end

function objAnim.getWidth(self)
    return self.width
end

function objAnim.getHeight(self)
    return self.height
end

function objAnim.activeInput(self, up, down, left, right)
    self.activeInputs = true
    self.up = up
    self.down = down
    self.left = left
    self.right = right    
end

function objAnim.setPhySpeed(self, phySpeed)
    self.phySpeed = phySpeed
end

function objAnim.setPlatformOrPhysic(self, platformOrPhysic)
    self.isPlatformOrPhysic = platformOrPhysic
end

function physicsInputs(self)
    if (self.physic and self.activeInputs and self.isPlatformOrPhysic == "physic") then   
        if love.keyboard.isDown(self.right) then
            self.direction = 1
            self.physic.body:applyForce(self.phySpeed, 0)
        elseif love.keyboard.isDown(self.left) then
            self.direction = -1
            self.physic.body:applyForce(-self.phySpeed, 0)
        end
        if love.keyboard.isDown(self.up) then
            self.physic.body:applyForce(0, -self.phySpeed)
        elseif love.keyboard.isDown(self.down) then
            self.physic.body:applyForce(0, self.phySpeed)
        end        
    end
end

function objAnim.setPlatformValues(self, speed, gravity, mass)
    self.speed = speed
    self.gravity = gravity
    self.mass = mass
end

function platformInputs(self, dt)

    if(self.activeInputs and self.isPlatformOrPhysic == "platform") then
        if love.keyboard.isDown(self.right) then
            self.direction = 1
            self.x = self.x + dt * self.speed    
        elseif love.keyboard.isDown(self.left) then
            self.direction = -1
            self.x = self.x - dt * self.speed
        end
    end

end

function objAnim.getState(self)
    return self.state
end

function updateState(self)
    if self then
        if self.lastY < self.y then
            self.state = "falling"
        elseif self.lastY > self.y then
            self.stand = "jumping"
        elseif self.lastX == self.x then
            self.state = "standing"  
        elseif self.lastX > self.x or self.lastX < self.x then
            self.state = "moving"
        end    
        self.lastX = self.x
        self.lastY = self.y
    end
end


function addObjectInWorld(object)
    table.insert(__world__, object)
    object.indexWorld = table.getn(__world__)
end

function checkCollision(self)
    if self then
        local w = __world__[self.indexWorld]
    end    
end
