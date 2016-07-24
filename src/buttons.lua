local function pipeCmd (cmd)
    local ret
    local command = io.popen(cmd)
    local tmp = command:read("*a")
    io.close(command)
    ret = string.gsub(tmp, "\n", "") -- Remove line break
    return ret
end

function getNumber(str)
  return str:match("%d+%.%d+")
end

function getValue(html, tokenStart, tokenEnd)
	local txt
	i, j = string.find(html, tokenStart)
	if j ~= nil then
    -- j + 1 para evitar que la ocurrencia apareza de forma
    -- inmediata
		m, n = string.find(html, tokenEnd, j + 1)
		txt = string.sub(html, j+1 , m-1)
		-- Removing whitespace at the beginning and at the end of a string
		return txt:match("^%s*(.-)%s*$")
	else
		return nil
	end
end

function love.load()
  font = love.graphics.newFont(48)
  myStyle = uare.newStyle({
		width = 40,
		height = 60,  
		--color
		color = {200, 200, 200},
		hoverColor = {150, 150, 150},
		holdColor = {100, 100, 100},
		--border
		border = {
			color = {255, 255, 255},
			hoverColor = {200, 200, 200},
			holdColor = {150, 150, 150},
			size = 5
		},    
    --text
    text = {
      color = {200, 0, 0},
      hoverColor = {150, 0, 0},
      holdColor = {255, 255, 255},
      font = font,
      align = "center",
      offset = {
        x = 0,
        y = -30
      }
    },
  })

  myButton = uare.new({
    text = {
      display = "Get"
    },
    x = WWIDTH*.5-90,
    y = WHEIGHT*.5-30,
    width = 180,
    onClick = function()
        myButton.y = myButton.y+2
        --
        url = love.system.getClipboardText()
        
        i, j = url:find("http://www.digikey.com/product.detail")
        
        if(i == 1) then
          html = pipeCmd("curl -L --user-agent Mozilla/4.0 --silent "..url)

          ordercode = getValue(html, "<meta itemprop=\"productID\" content=\"sku:", "\"")
          manufacturer = getValue(html, "<span itemprop=\"name\">", "</span>")
          manucode = getValue(html, "<meta itemprop=\"name\" content=\"", "\"")
          description = getValue(html, "<td itemprop=\"description\">", "</td>")
          priceunit = getNumber(getValue(html, "id=\"schema%poffer\"", "</span>"))

          love.system.setClipboardText([[
{SUPPLIER=DigiKey}
{DESC=]]..description..[[}
{ORDERCODE=]]..ordercode..[[}
{MANUFACTURER=]]..manufacturer..[[}
{MANCODE=]]..manucode..[[}
{PRICE=]]..priceunit..[[}
{PRICEQTY=1}
{URL=]]..url..[[}
          ]])
          myButton.text.color = {0, 200, 0}
        else
          myButton.text.color = {200, 0, 0}
        end
      end,
    onRelease = function() 
      myButton.y = myButton.y-2
    end
  }):style(myStyle)
end

function love.update(dt)
  uare.update(dt, love.mouse.getX(), love.mouse.getY())
end

function love.draw()
  uare.draw()
end
