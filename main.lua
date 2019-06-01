
require 'lib/obj_anim'

function love.load()

  naruto = objAnim.new({"res/spt_naruto_parado.png", "res/spt_naruto_correndo.png", 
                        "res/spt_naruto_pulando.png", "res/spt_naruto_caindo.png"}) --passa tabela com as sheets das sprites
  naruto:createAnim(1, 3, 2, 6, 8, true, false) -- qual sheet, qtd linhas, qtd colunas, index do ultimo sprite, frame rate, se fica em loop, se é uma imagem statica
  naruto:createAnim(2, 3, 2, 6, 12, true, false)
  naruto:createAnim(3, 2, 1, 2, 8, true, false)
  naruto:createAnim(4, 2, 1, 2, 8, true, false)
  naruto:setCurrentAnimation(1) -- especifica qual animação deve mostrar
  naruto:setDirection(1) -- especifica a direção da imagem onde 1 = normal, -1 = espelhada
  naruto:setScaleWH(1, 1) -- seta o tamanho da imagem tanto pra width quanto pra height onde 1 = tamanho original em pixels
  naruto:setPosXY(200,300) -- seta a posicao de x e y da imagem
  naruto:activeInput("up", "down", "left", "right") -- seta os inputes basicos de movimentação
  naruto:setPlatformOrPhysic("platform") -- seta a forma em que o objeto vai ser comportar (modo jogo plataforma 2d, ou modo jogo com aplicação de física)
  naruto:setPlatformValues(400, 300, 0) -- seta a velocidade, gravidade e a massa do objeto em jogo de plataforma
  addObjectInWorld(naruto) -- adiciona o objeto no mundo para aplicar colisões (todos os objetos adicionados ao mundo, irão colidir)

end

function love.update(dt)    
  
  if naruto:getState() == "standing" then
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

  naruto:update(dt) -- atualiza a animação  

end

function love.draw()
  naruto:anim() -- desenha a animação
end


