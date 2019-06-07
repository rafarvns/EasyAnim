
__world__ = {}
easyAnim = {}
easyAnim.__index = easyAnim

function easyAnim.new(sprites)
    local self = setmetatable({}, easyAnim)
    
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
    self.name = "x" .. love.math.random() +1 .. "xx"

    self.isPlatformOrPhysic = "platform"

    --PLATFORM PLATFORM ATTRIBUTES
    self.speed = 0
    self.gravity = 0
    self.mass = 100
    self.massInc = 0
    self.state = "stand"
    self.lastX = 0
    self.lastY = 0
    self.indexWorld = 0
    self.percentW = 1
    self.percentH = 1   

    --collisions attributes
    self.collisionType = "none"
    self.whoCollide = ""
    self.isEnemy = false

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

function easyAnim.createAnim(self, sprite_id, rows, cols, last_sprite, frameRate, mov_speed, isLoop, static)
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
        endLoop = false,
        speed = 0
    }    

    animation_data.frames = sprites_arr
    animation_data.frameRate = frameRate
    animation_data.last_spt = last_sprite
    animation_data.speed = mov_speed
    animation_data.isLoop = isLoop
    animation_data.endLoop = static
    table.insert(self.list_animations_data, animation_data)
    self.width = qX
    self.height = qY
    self.w = qX
    self.h = qY
end

function easyAnim.update(self, dt)

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
        self.collisionType = "none"
        platformInputs(self, dt)

        if self.state ~= "jumping" then
            if(self.massInc < self.mass) then
                self.massInc = self.massInc + dt * self.gravity * self.mass
            end
            if not checkCollision(self, self.x, self.y + dt * self.gravity * self.massInc) then
                self.y = self.y + dt * self.gravity * self.massInc
            else
                self.collisionType = self.whoCollide .. "ground"
            end
        else
            self.massInc = self.massInc - dt * ((self.gravity * self.mass) / 4)
            if not checkCollision(self, self.x, self.y - dt * self.gravity * self.massInc) then
                self.y = self.y - dt * self.gravity * self.massInc
            else
                self.collisionType = self.whoCollide .. "head"
            end
        end
        
        updateState(self)
        
    end

end

function easyAnim.anim(self)

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

function easyAnim.reAnim(self)
    self.current_animation.currentFrame = 1
    self.current_animation.endLoop = false
end

function easyAnim.isEndAnim(self)
    return self.current_animation.endLoop
end

function easyAnim.setCurrentAnimation(self, index)
    self.index_animation = index
    self.current_animation = self.list_animations_data[index]
    self.speed = self.current_animation.speed
    self.current_animation.endLoop = false
end

function easyAnim.getCurrentAnimation(self)
    return self.index_animation
end

function easyAnim.setPhysics(self, world, mass, phySpeed)
    self.physic.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physic.body:setMass(mass)
    self.physic.shape = love.physics.newRectangleShape(self.width / 2, self.height / 2)
    self.physic.fixture = love.physics.newFixture(self.physic.body, self.physic.shape)
    self.physic.fixture:setRestitution(0)
    self.physic.fixture:getUserData("Character")
    self.phySpeed = phySpeed
end

function easyAnim.setPosX(self, x)
    if (self.physic.body) then
        self.physic.body:setX(self.physic.body:getX() + (self.width / 2))
    else
        self.x = x + (self.width / 2)
        self.lastX = self.x
    end
end

function easyAnim.setPosY(self, y)
    if (self.physic.body) then
        self.physic.body:setY(self.physic.body:getY() - (self.height / 2))
    else
        self.y = y - (self.height / 2)
        self.lastY = self.y
    end    
end

function easyAnim.getPosX(self)
    return self.x - (self.width / 2)
end

function easyAnim.getPosY(self)
    return self.y + (self.height / 2)
end

function easyAnim.setPosXY(self, x, y)
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

function easyAnim.getPosXY(self)
    return {self.x - (self.width / 2), self.y + (self.height / 2)}
end

function easyAnim.setDirection(self, direction)
    self.direction = direction
end

function easyAnim.getDirection(self)
    return self.direction
end

function easyAnim.setRotation(self, rotation)
    self.rotation = rotation
end

function easyAnim.getRotation(self)
    return self.rotation
end

function easyAnim.setScaleW(self, scaleW)
    self.scaleW = scaleW
    self.width = scaleW * self.w
end

function easyAnim.getScaleW(self)
    return self.scaleW
end

function easyAnim.setScaleH(self, scaleH)
    self.scaleH = scaleH
    self.height = scaleH * self.h
end

function easyAnim.setScaleWH(self, scaleW, scaleH)
    self.scaleW = scaleW
    self.width = scaleW * self.w
    self.scaleH = scaleH
    self.height = scaleH * self.h
end

function easyAnim.getScaleH(self)
    return self.scaleH
end

function easyAnim.getWidth(self)
    return self.width
end

function easyAnim.getHeight(self)
    return self.height
end

function easyAnim.activeInput(self, up, down, left, right, jump)
    self.activeInputs = true
    self.up = up
    self.down = down
    self.left = left
    self.right = right    
    self.jump = jump
end

function easyAnim.setPhySpeed(self, phySpeed)
    self.phySpeed = phySpeed
end

function easyAnim.isEnemy(self, isEnemy)
    self.isEnemy = isEnemy
end

function easyAnim.getCollisionType(self)
    return self.collisionType
end

function easyAnim.setPlatformOrPhysic(self, platformOrPhysic)
    self.isPlatformOrPhysic = platformOrPhysic
end

function easyAnim.setName(self, name)
    self.name = name
end

function easyAnim.getName(self)
    return self.name
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

function easyAnim.setGravity(self, gravity)
    self.gravity = gravity
end

function platformInputs(self, dt)

    if(self.activeInputs and self.isPlatformOrPhysic == "platform") then
        local movSpeed = 1
        if self.state == "jumping" or self.state == "falling" then
            movSpeed = 1    
        end

        if love.keyboard.isDown(self.jump) and (self.state == "standing" or self.state == "moving") then
            self.state = "jumping"
        end

        if love.keyboard.isDown(self.right) then
            self.direction = 1            
            if not checkCollision(self, self.x + dt * self.speed / movSpeed, self.y) then
                self.x = self.x + dt * self.speed / movSpeed
            else
                local enemy = ""
                if self.isEnemy then
                    enemy = "-enemy"
                end
                self.collisionType = self.whoCollide .. "rightside"
            end
        elseif love.keyboard.isDown(self.left) then
            self.direction = -1
            if not checkCollision(self, self.x - dt * self.speed / movSpeed, self.y) then
                self.x = self.x - dt * self.speed / movSpeed
            else
                local enemy = ""
                if self.isEnemy then
                    enemy = "-enemy"
                end
                self.collisionType = self.whoCollide .. "leftside"
            end
        end



    end

end


function easyAnim.setPercentHitBox(self, percentW, percentH)
    self.percentW = percentH
    self.percentH = percentH
end

function easyAnim.getState(self)
    return self.state
end

function updateState(self)
    if self then
        if self.lastY < self.y then
            self.state = "falling"
        elseif self.lastY > self.y then
            self.state = "jumping" 
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

function checkCollision(self, px, py)
    if self then
        local me = {
            x = px,
            y = py,
            width = self.width,
            height = self.height
        }
        for i, obj in ipairs(__world__) do
            if i ~= self.indexWorld then
                if collide(me.x - (me.width / 2), me.y - (me.height / 2), me.width / self.percentW, me.height / self.percentH, 
                                obj.x - (obj.width / 2), obj.y - (obj.height / 2), obj.width / obj.percentW, obj.height / obj.percentH) then
                    local enemy = ""
                    if obj.isEnemy then
                        enemy = "enemy-"
                    end
                    enemy = enemy .. obj.name .. "-"
                    self.whoCollide = enemy
                    return true
                end
            end
        end
    end    
    self.whoCollide = ""
    return false
end

function collide(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

