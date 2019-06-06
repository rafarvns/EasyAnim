
require 'lib/easy_anim'

function love.load()

  background = love.graphics.newImage("res/background.jpg")

  chao = easyAnim.new({"res/pixel_transparente.png"})
  chao:createAnim(1,1,1,1,0,false,true)
  chao:setCurrentAnimation(1)
  chao:setPosXY(0, 445)
  chao:setScaleWH(1000*2, 1)
  chao:setPlatformOrPhysic("platform")
  chao:setGravity(0)
  chao:setPercentHitBox(1,1)
  chao:setName("chao")
  addObjectInWorld(chao)

  naruto = easyAnim.new({"res/spt_sakura_parado.png", "res/spt_sakura_correndo.png", 
                        "res/spt_sakura_pulando.png", "res/spt_sakura_caindo.png",
                        "res/spt_sakura_arremessando.png", "res/spt_sakura_batendo.png"}) --passa tabela com as sheets das sprites
  naruto:createAnim(1, 3, 2, 6, 8, 1, true, false) -- qual sheet, qtd linhas, qtd colunas, index do ultimo sprite, frame rate, movSpeed, se fica em loop, se é uma imagem statica
  naruto:createAnim(2, 3, 2, 6, 12, 500, true, false)
  naruto:createAnim(3, 2, 1, 2, 8, 500, true, false)
  naruto:createAnim(4, 2, 1, 2, 8, 500, true, false)
  naruto:createAnim(5, 2, 2, 3, 12, 500, false, false)
  naruto:createAnim(6, 4, 4, 13, 12, 500, false, false)
  naruto:setCurrentAnimation(1) -- especifica qual animação deve mostrar
  naruto:setDirection(1) -- especifica a direção da imagem onde 1 = normal, -1 = espelhada
  naruto:setScaleWH(1, 1) -- seta o tamanho da imagem tanto pra width quanto pra height onde 1 = tamanho original em pixels
  naruto:setPosXY(200,200) -- seta a posicao de x e y da imagem
  naruto:activeInput("up", "down", "left", "right", "up") -- seta os inputes basicos
  naruto:setPlatformOrPhysic("platform") -- seta a forma em que o objeto vai ser comportar (modo jogo plataforma 2d, ou modo jogo com aplicação de física)
  naruto:setGravity(10) -- seta a velocidade, gravidade e a massa do objeto em jogo de plataforma
  naruto:setPercentHitBox(1.6, 1.6)
  naruto:setName("narutinho")
  addObjectInWorld(naruto) -- adiciona o objeto no mundo para aplicar colisões (todos os objetos adicionados ao mundo, irão colidir)
  inThrow = false
  inJab = false
  dispara = false
  projeteis = {}

  naruto2 = easyAnim.new({"res/spt_sasuke_parado.png", "res/spt_sasuke_correndo.png", 
                            "res/spt_sasuke_pulando.png", "res/spt_sasuke_caindo.png"}) --passa tabela com as sheets das sprites
  naruto2:createAnim(1, 3, 2, 6, 8, 1, true, false) -- qual sheet, qtd linhas, qtd colunas, index do ultimo sprite, frame rate, se fica em loop, se é uma imagem statica
  naruto2:createAnim(2, 3, 2, 6, 12, 500, true, false)
  naruto2:createAnim(3, 2, 2, 3, 8, 500, true, false)
  naruto2:createAnim(4, 2, 2, 3, 8, 500, true, false)
  naruto2:setCurrentAnimation(1) -- especifica qual animação deve mostrar
  naruto2:setDirection(-1) -- especifica a direção da imagem onde 1 = normal, -1 = espelhada
  naruto2:setScaleWH(1, 1) -- seta o tamanho da imagem tanto pra width quanto pra height onde 1 = tamanho original em pixels
  naruto2:setPosXY(300, 180) -- seta a posicao de x e y da imagem
  naruto2:setPercentHitBox(1.6, 1.6)
  naruto2:setPlatformOrPhysic("platform") 
  naruto:setName("sask")
  naruto2:setGravity(10)
  addObjectInWorld(naruto2)

end

function love.update(dt)    
  
  if dispara then
    dispara = false
    local projetil = {
      x = naruto:getPosX() + 40,
      y = naruto:getPosY() - 80,  
      dir = naruto:getDirection()    
    }
    table.insert(projeteis, projetil)
  end

  if naruto:isEndAnim() then
    inThrow = false
    inJab = false
  end

    if inJab then
      naruto:setCurrentAnimation(6)
    elseif inThrow then
      naruto:setCurrentAnimation(5)
    elseif naruto:getState() == "standing" then
      naruto:setCurrentAnimation(1)    
    elseif naruto:getState() == "moving" then
      naruto:setCurrentAnimation(2)
    elseif naruto:getState() == "falling" then
      naruto:setCurrentAnimation(3)
    elseif naruto:getState() == "jumping" then
      naruto:setCurrentAnimation(4)
    else
      naruto:setCurrentAnimation(1)
    end
  
  for i, proj in ipairs(projeteis) do
    if(proj.x < -100 or proj.x > 1400)then
      table.remove(projeteis, i)
      break;
    end
    proj.x = proj.x + dt * 1200 * proj.dir    
  end

  naruto:update(dt) -- atualiza a animação  
  naruto2:update(dt)
  chao:update(dt)

end

function love.draw()
  love.graphics.draw(background, 0, -50, 0)

  
  for i, proj in ipairs(projeteis) do
    print(proj.x)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle( "fill", proj.x, proj.y, 8, 8 )
  end

  naruto:anim() -- desenha a animação
  naruto2:anim()


  chao:anim()
end

function love.keypressed(key)
  if key == "c" and not inThrow then
    naruto:reAnim()    
    inThrow = true
    dispara = true
  end

  if key == "v" and not inJab then
    naruto:reAnim()
    inJab = true
  end
end

