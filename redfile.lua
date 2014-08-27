--Easy to use RedNet file Sender and Receiver with graphical interface
--    - To open file browser just run the program
--      - In file browser you can choose your file, open menu (press m) and send it to any other computer that has this program
--      - File browser also has functions like open, edit, create folder/file, delete
--    - You can also run this program with arguments (this way you can send and get files using other programs; eg.: shell.run("RedFile", "send", "14", "myfile"))
--      - Sending: RedFile send <computer id> <file>
--          RedFile - this program
--          send - 1st argument tells what to do, in this case 'send'
--          <computer id> - 2nd argument is ID of computer that you want to send to (recipient)
--          <file> 3rd argument is file you want to send
--          
--          Example: RedFile send 28 myprogram
--        
--      - Getting: RedFile get <computer id>
--          RedFile - this program
--          get - 1st argument tells what to do, in this case 'get'
--          <computer id> - 2nd argument is optional; use it if you want to get file from a specific computer
--          
--          Example: RedFile get 28
--     
--     features:
--       - Sending any type of file with any characters
--       - When getting a file you can save it where ever you want
--       - If there is 1 modem attached on a computer - uses that; If there is more than 1 modem - lets you choose wich one you want to use
--       - See proggress in percents when sending and getting a file (try sending rom/programs/secret/alongtimeago, it will crash when it will try to save it, but you will see how it shows the proggress)
--       - You can use this as your file browser
--       - Working on Advanced and normal computers

local version = "1.3"
local sides = {}
local side = ""
local col = term.isColor()
local arg = {...}
local path = ""
local sendID = 0
local sendb = false
local getb = false
local running = true
local programName = shell.getRunningProgram()

--Helper functions

local function getSides ()
  local sides = {}
  
  for _, sid in pairs(rs.getSides()) do
    if peripheral.isPresent(sid) and peripheral.getType(sid) == "modem" then
     sides[#sides + 1] = sid
    end
  end
  
  return sides
end

local function clear ()
  term.clear()
  term.setCursorPos(1, 1)
end

local function resetColors ()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end

local function reset ()
  resetColors()
  clear()
end

local function conTColor (ColorColor)
  if col or ColorColor == colors.white or ColorColor == colors.black then
    return ColorColor or colors.white
  else
    return colors.black
  end
end

local function conBColor (ColorColor)
  if col or ColorColor == colors.white or ColorColor == colors.black then
    return ColorColor or colors.black
  else
    return colors.white
  end
end

local function writeText (text, tColor, bColor, x, y, clear)
  if not x then
    x = term.getCursorPos()
  end
  
  if not y then
    _, y = term.getCursorPos()
  end
  
  if tColor then
    term.setTextColor(conTColor(tColor))
  end
  
  if bColor then
    term.setBackgroundColor(conBColor(bColor))
  end
  
  term.setCursorPos(x, y)
  
  if clear == true then
    term.clear()
  end
  
  term.write(tostring(text))
end

local function vRep (text, times, tColor, bColor, x, y)
  local w, h = term.getSize()
  
  if not x then
    x = term.getCursorPos()
  end
  
  if not y then
    _, y = term.getCursorPos()
  end
  
  times = times or 1
  
  for i = 1, times do
    writeText(text, tColor, bColor, x, y)
    y = y + 1
  end
end

local function clamp (Number, min, max)
  if Number < min then
    return min
  elseif Number > max then
    return max
  else
    return Number
  end
end

local function round (Number)
  return math.floor(Number + 0.5)
end

local function getMin (...)
  local arg = {...}
  local num
  
  for i, number in pairs(arg) do
    if not arg[i - 1] then
      num = tonumber(number)
    else
      if tonumber(number) < num then
        num = number
      end
    end
  end
  
  return num
end

local function getMax (...)
  local arg = {...}
  local num
  
  for i, number in pairs(arg) do
    if not arg[i - 1] then
      num = tonumber(number)
    else
      if tonumber(number) > num then
        num = number
      end
    end
  end
  
  return num
end

local function selectionMenu(TableSelections, NumberKey, limit)
  local xO, yO = term.getCursorPos()
  local x, y = term.getCursorPos()
  local xm, ym = term.getCursorPos()
  local w, h = term.getSize()
  local selection = 1
  local pos = 1
  local enable = false
  
  limit = limit or #TableSelections
  
  local function scroll ()
    if selection < pos then
      pos = selection
    elseif selection > pos + limit - 1 then
      pos = selection - limit + 1
    end
  end
  
  while true do
  x, y = xO + 1, yO
  term.setCursorPos(x, y)
  
  scroll()
  
  for n = pos, getMin(#TableSelections, limit + pos - 1) do
    resetColors()
    
    if TableSelections[n] == "" then
      term.setCursorPos(x, y)
      term.write(TableSelections[n])
      y = y + 1
    elseif TableSelections[n] then
      term.setCursorPos(x, y)
      
      if selection == n then
        term.setBackgroundColor(conBColor(colors.blue))
        term.setTextColor(conTColor(colors.yellow))
      end
      
      term.write(TableSelections[n]) 
      y = y + 1
    end
  end
  
  resetColors()
  
  x, y = xO, yO
  term.setCursorPos(x, y)
  
  if #TableSelections > 1 then
    local b = limit < #TableSelections
    local limit = getMin(#TableSelections, limit)
    term.setBackgroundColor(conBColor(colors.blue))
    term.setTextColor(conTColor(colors.yellow))
    
    local start = getMax(round(pos / #TableSelections * limit), 1)
    local finish = getMin(start + getMax(round(limit / #TableSelections * limit), 1), limit)
    
    for n = start, finish do
      term.setCursorPos(x, y + n - 1)
      term.write(" ")
    end
  end
  
  local event, p1, x, y = os.pullEvent()
  
  if event == "key" then
    if p1 == keys.down then
      repeat
        selection = selection + 1
      until TableSelections[selection] ~= "" or selection <= 1
    elseif p1 == keys.up then
      repeat
        selection = selection - 1
      until TableSelections[selection] ~= "" or selection >= #TableSelections
    elseif p1 == keys.enter then
      return selection
    elseif NumberKey and p1 == NumberKey then
      return selection, true
    else
      x, y = xO, yO
      term.setCursorPos(x, y)
    end
  elseif event == "mouse_scroll" then
    if p1 < 0 then
      repeat
        selection = selection - 1
      until TableSelections[selection] ~= "" or selection >= #TableSelections
    else
      repeat
        selection = selection + 1
      until TableSelections[selection] ~= "" or selection <= 1
    end
  elseif event == "mouse_click" then
    local xw, yw = xO, yO
    xp, yp = xO, yO
    local ok = false
    
    enable = false
    
    for n = pos, getMin(#TableSelections, limit + pos - 1) do
      if y == yw and x >= xw + 1 and x <= xw + #TableSelections[n] then
        selection = n
        ok = true
        break
      end
      
      yw = yw + 1
    end
    
    if not ok then
      local limit = getMin(#TableSelections, limit)
      local start = getMax(round(pos / #TableSelections * (limit)), 1)
      local finish = getMin(start + getMax(round(limit / #TableSelections * limit), 1), limit)
      
      for n = start, finish do
        term.setCursorPos(xp, yp + n - 1)
        term.write(" ")
        
        if x == xp and y == yp + n - 1 then
          enable = true
          break
        end
      end
    end
    
    if ok == true and p1 == 1 then
      return selection
    elseif p1 == 2 then
      return selection, true
    end
  elseif event == "mouse_drag" and enable == true then
    local moved = clamp(y - ym, -1, 1)
    
    if moved > 0 then
      local limit = getMin(#TableSelections, limit)
      local start = getMax(round(pos / #TableSelections * limit), 1)
      local finish = getMin(start + getMax(round(limit / #TableSelections * limit), 1), limit) + 1
      
      local temp = round(finish / limit * #TableSelections)
      
      selection = temp
    else
      local limit = getMin(#TableSelections, limit)
      local start = getMax(round(pos / #TableSelections * limit), 1) - 1
      
      local temp = round(start / limit * #TableSelections)
      
      selection = temp
    end
    
    xm, ym = x, y
  end
  
  x, y = xO, yO
  term.setCursorPos(x, y)
  
  for n = pos, getMin(#TableSelections, limit + pos - 1) do
    if TableSelections[n] then
      resetColors()
      term.setCursorPos(x, y)
      term.write(string.rep(" ", #TableSelections[n] + 1))
      y = y + 1
    end
  end
  
  selection = clamp(selection, 1, #TableSelections)
  end
end

local function closeSides ()
  sides = getSides()
  
  if #sides > 0 then
    for _, s in pairs(sides) do
      rednet.close(s)
    end
  end
end

local function readAll (StringPath)
  if not fs.exists(StringPath) then
    return
  end
  
  local file = fs.open(StringPath, "r")
  local line = file.readLine()
  local lines = {}
  
  while line ~= nil do
    table.insert(lines, line)
    line = file.readLine()
  end
  
  file.close()
  
  return lines
end

local function list (StringPath, StringType)
  if not fs.isDir(StringPath) then
    return
  end
  
  local list = {}
  local files = {}
  
  if string.sub(StringPath, #StringPath - 1) ~= "/" then
    StringPath = StringPath .. "/"
  end
  
  list = fs.list(StringPath)
  
  if list ~= {} then
    if StringType == "files" or StringType == "file" or StringType == "doc" or StringType == "document" or StringType == "documents" then
      for _, file in pairs(list) do
        if not fs.isDir(StringPath .. file) and fs.exists(StringPath .. file) then
          table.insert(files, file)
        end
      end
    elseif StringType == "folders" or StringType == "directories" or StringType == "folder" or StringType == "dir" or StringType == "directorie" then
      for _, file in pairs(list) do
        if fs.isDir(StringPath .. file) then
          table.insert(files, file .. "/")
        end
      end
    else
      files = list
    end
  end
  
  table.sort(files)
  
  return files
end

local function toString (TableText)
  local text = ""
  
  for i = 1, #TableText do
    text = text .. TableText[i] .. "\n"
  end
  
  text = text:sub(1, #text - 1)
  
  return text
end

local function formatString(Text)
  if Text:len() == 0 then
    return
  end
  
  return string.upper(Text:sub(1, 1)) .. string.lower(Text:sub(2))
end

local function writeAll (StringPath, StringText)
  local file = fs.open(StringPath, "w")
  
  file.write(StringText or "")
  
  file.close()
end

local function getSize (StringPath)
  if not fs.exists(StringPath) or fs.isDir(StringPath) then
    return nil
  end
  
  local file = fs.open(StringPath, "rb")
  local text = file.read()
  local len = 0
  
  while text ~= nil do
    len = len + 1
    text = file.read()
  end
  
  return len
end

local function checkFolders (text)
  local folders = {}
  local p1, p2
  local path = ""
  
  text = shell.resolve(text)
  
  for i = 1, #text do
    if text:sub(i, i) ~= "/" then
      if not p1 then
        p1 = i
      end
      
      if i == #text then
        folders[#folders + 1] = text:sub(p1)
      end
    else
      p2 = i - 1
      
      folders[#folders + 1] = text:sub(p1, p2)
      
      p1, p2 = nil, nil
    end
  end
  
  for _, folder in pairs(folders) do
    if not fs.isDir(folder) then
      fs.makeDir(path .. folder)
    end
    
    path = path .. folder .. "/"
  end
end

--Error checking and setting variables

local function usage (err)
  if err then
    writeText(err, colors.yellow)
    print()
  end
  
  resetColors()
  
  print("Usage:")
  print(programName .. " send <computer id> <file to send>")
  print(programName .. " get <computer id>")
  print()
  print("Don't use any arguments to run GUI version of this utility.")
  print()
  print('Ps: only specify "<computer id>" when getting a file if you want to get it from a specific computer.')
  
  error()
end

if #arg > 0 then
  if arg[1]:lower() == "send" then
    if #arg == 3 then
      if fs.exists(arg[3]) and not fs.isDir(arg[3]) then
        path = arg[3]
      else
        usage("Invalid argument (3); specified file doesn't exist.")
      end
      
      if tonumber(arg[2]) and tonumber(arg[2]) > 0 then
        sendID = tonumber(arg[2])
      else
        usage("Invalid argument (2); specified computer id is not valid.")
      end
    else
      usage()
    end
    
    sendb = true
  elseif arg[1]:lower() == "get" then
    if tonumber(arg[2]) and tonumber(arg[2]) > 0 then
      sendID = tonumber(arg[2])
    end
    
    getb = true
  else
    usage()
  end
end

--{{Main Code}}

local function drawFrame (small, ColorClear)
  local x, y = 1, 1
  local w, h = term.getSize()
  
  if small == true then
    x = w / 4
    y = h / 4
    w = w / 2
    h = h / 2
    
    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)
    w = math.floor(w + 0.5)
    h = math.floor(h + 0.5)
  end
  
  vRep(" ", h, nil, colors.lightBlue, x, y)
  vRep(" ", h, nil, colors.lightBlue, x + w - 1, y)
  writeText(string.rep(" ", w), nil, colors.lightBlue, x, y)
  writeText(string.rep(" ", w), nil, colors.lightBlue, x, y + h - 1)
  
  for x = x + 1, w + x - 2 do
    for y = y + 1, h + y - 2 do
      writeText(" ", nil, ColorClear or colors.black, x, y)
    end
  end
  
  resetColors()
end

local function window (TableContent)
  local x, y = 1, 1
  local w, h = term.getSize()
  
  w, h = w - 1, h - 1
  x, y = w / 4 + 2, h / 4 + 2
  
  drawFrame(true)
  
  for i = 1, #TableContent do
    writeText(TableContent[i], nil, nil, x, y + i - 1)
  end
end

--Checking for modems

local function waitForModem ()
  drawFrame(true)
  
  local x, y = 1, 1
  local w, h = term.getSize()
  
  w, h = w - 1, h - 1
  
  while running do
    sides = getSides()
    x, y = w / 4 + 2, h / 4 + 2
    
    if #sides > 0 then
      for i, side in pairs(sides) do
        sides[i] = formatString(side)
      end
      
      if #sides == 1 then
        side = sides[1]:lower()
        running = false
      else
        writeText("Select modem:", nil, nil, x, y)
        term.setCursorPos(x, y + 1)
        
        side = sides[selectionMenu(sides)]:lower()
        running = false
      end
    else
      writeText("Attach a modem", nil, nil, x, y)
      writeText("Press any key to cancel", nil, nil, x, y + 2)
      
      repeat
        local event, side = os.pullEvent()
        
        if event == "key" then
          return false
        end
      until event == "peripheral" and peripheral.getType(side) == "modem"
    end
  end
  
  rednet.open(side)
  
  running = true
  return true
end

--Sending function

local function send ()
  if not waitForModem() then
    return false
  end
  
  local event, id, message
  local name = fs.getName(path)
  local percent = 0
  local file = toString(readAll(path))
  local subfile = ""
  local i = 0
  local x, y = 1, 1
  local w, h = term.getSize()
  
  w, h = w - 1, h - 1
  x, y = w / 4 + 2, h / 4 + 2
  
  local function toPercent ()
    local per = tostring(percent)
    
    while #per < 3 do
      per = per .. " "
    end
    
    return per
  end
  
  while running do
    window({"Waiting for recipient ".. sendID, "Press \"R\" to retry", "", "Press any key to cancel"})
    
    rednet.send(sendID, "request " .. getSize(path) .. ">" .. name)
    
    repeat
      event, id, message = os.pullEvent()
      
      if event == "key" then
        if id == keys.r then
          rednet.send(sendID, "request " .. getSize(path) .. ">" .. name)
        else
          closeSides()
          return false
        end
      end
    until event == "rednet_message" and id == sendID
    
    if message == "get" then
      window({"Sending: " .. name, percent .. "%"})
      
      if #file <= 500 then
        writeText(percent .. "%", nil, nil, x, y + 1)
        
        rednet.send(sendID, toPercent() .. " " .. file)
        
        repeat
          event, id = os.pullEvent("rednet_message")
        until id == sendID
        
        rednet.send(sendID, "sent")
        
        closeSides()
        
        window({"Successfully sent:", name, "", "Press any key to exit"})
        os.pullEvent("key")
        return true
      else
        while true do
        if i ~= #file then
          writeText(percent .. "%", nil, nil, x, y + 1)
          
          if #file <= i + 500 then
            subfile = file:sub(i + 1)
            
            i = #file
          else
            subfile = file:sub(i + 1, i + 500)
            
            percent = math.floor(i / #file * 100)
            i = i + 500
          end
          
          rednet.send(sendID, toPercent() .. " " .. subfile)
          
          repeat
            event, id = os.pullEvent("rednet_message")
          until id == sendID
        else
          rednet.send(sendID, "sent")
          
          closeSides()
          
          window({"Successfully sent:", name, "", "Press any key to exit"})
          os.pullEvent("key")
          return true
        end
        end
      end
    elseif message == "refuse" then
      closeSides()
      window({"Recipient refused", "", "Press any key to exit"})
      os.pullEvent("key")
      return false
    end
  end
  
  running = true
  
  closeSides()
end

--Getting function

local function get ()
  if not waitForModem() then
    return false
  end
  
  local getName = "unknown"
  local text = {"Waiting for request", "Sender ID: any", "", "Press any key to cancel"}
  local event, id, message
  local selection = 0
  local percent = 0
  local file = ""
  local size = ""
  local x, y = 1, 1
  local w, h = term.getSize()
  
  w, h = w - 1, h - 1
  x, y = w / 4 + 2, h / 4 + 2
  
  if sendID ~= 0 then
    text[2] = "Sender ID: " .. sendID
  end
  
  while running do
    window(text)
    
    repeat
      event, id, message = os.pullEvent()
      
      if event == "key" then
        closeSides()
        return false
      end
    until event == "rednet_message" and (id == sendID or sendID == 0)
    
    if sendID == 0 then
      sendID = id
    end
    
    if message:sub(1, 7) == "request" then
      local p1 = message:find(">")
      
      if fs.getFreeSpace("/") < tonumber(message:sub(9, p1 - 1)) then
        rednet.send(sendID, "refuse")
        closeSides()
        window({"File to big", "", "Press any key"})
        os.pullEvent("key")
        return false
      end
      
      size = (tonumber(message:sub(9, p1 - 1)) / 1000) .. " kB"
      getName = message:sub(p1 + 1)
    end
    
    window({"Getting file from " .. sendID, "Name: " .. getName, "Size: " .. size})
    term.setCursorPos(x, y + 4)
    selection = selectionMenu({"Save", "Cancel"})
    
    if selection == 2 then
      rednet.send(sendID, "refuse")
      closeSides()
      return false
    else
      window({"Enter save path:"})
      term.setCursorPos(x, y + 1)
      path = shell.resolve(read())
      rednet.send(sendID, "get")
    end
    
    window({"Getting: " .. getName, percent .. "%"})
    
    repeat
      writeText(percent .. "%", nil, nil, x, y + 1)
      
      event, id, message = os.pullEvent("rednet_message")
      
      if id == sendID and message ~= "sent" then
        percent = tonumber(message:sub(1, 3))
        
        file = file .. message:sub(5)
        
        rednet.send(sendID, "ok")
      end
    until id == sendID and message == "sent"
    
    closeSides()
    
    window({"Saving: " .. getName, "Path: " .. path .. "/" .. getName})
    checkFolders(path)
    writeAll(path .. "/" .. getName, file)
    window({"Saved " .. getName, "Path: " .. path .. "/" .. getName, "", "Press any key to exit"})
    os.pullEvent("key")
    return true
  end
  
  running = true
  
  closeSides()
end

--Running program and File Manager

if sendb == true then
  send()
elseif getb == true then
  get()
else
  local currentPath = "/"
  local files = list(currentPath, "files")
  local folders = list(currentPath, "folders")
  local fileList = {}
  local x, y = 2, 2
  local w, h = term.getSize()
  local selection = 0
  local menu = false
  local selected = 0
  
  local function combine ()
    if #files == 0 then
      return folders
    end
    
    if #folders == 0 then
      return files
    end
    
    local all = folders
    
    for _, file in pairs(files) do
      all[#all + 1] = file
    end
    
    return all
  end
  
  local function back (StringPath)
    if StringPath == "/" then
      return StringPath
    end
    
    repeat
      StringPath = string.sub(StringPath, 1, #StringPath - 1)
    until string.sub(StringPath, #StringPath) == "/" or #StringPath <= 1
    
    return StringPath
  end
  
  local function getFolder (StringPath)
    local string = back(StringPath)
    
    return string.sub(StringPath, #string + 1)
  end
  
  while running do
    files = list(currentPath, "files")
    folders = list(currentPath, "folders")
    fileList = combine()
    
    table.insert(fileList, 1, "/")
    fileList[#fileList + 1] = ""
    fileList[#fileList + 1] = "Exit"
    
    if menu then
      local x, y = 1, 1
      local w, h = term.getSize()
      
      w, h = w - 1, h - 1
      x, y = w / 4 + 2, h / 4 + 2
      
      drawFrame(true)
      term.setCursorPos(x, y)
      selection = selectionMenu({"Open", "Edit", "Send", "Get", "New Folder", "New File", "Delete", "Close modems", "Help", "", "Back"}, nil, math.floor(h / 2) - 1)
      
      if selection == 1 then
        if selected then
          if fs.isDir(currentPath .. selected) then
            currentPath = currentPath .. selected
            menu = false
          else
            shell.run(currentPath .. selected)
            menu = false
          end
        else
          window({"Choose a file first", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 2 then
        if selected then
          if fs.isDir(currentPath .. selected) then
            window({"Can't edit a folder", "", "Press any key"})
            os.pullEvent("key")
            menu = false
          else
            shell.run("edit", currentPath .. selected)
            menu = false
          end
        else
          window({"Choose a file first", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 3 then
        if selected then
          path = currentPath .. selected
          window({"Enter recipient ID:"})
          term.setCursorPos(x, y + 1)
          sendID = tonumber(read()) or 0
          send()
          path = ""
          sendID = 0
          menu = false
        else
          window({"Choose a file first", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 4 then
        window({"Enter sender ID:", "", "", "Leave it blank if you", "don't know sender id"})
        term.setCursorPos(x, y + 1)
        sendID = tonumber(read()) or 0
        get()
        sendID = 0
        path = ""
        menu = false
      elseif selection == 5 then
        window({"Create new folder:"})
        term.setCursorPos(x, y + 1)
        local name = read()
        
        if not fs.exists(currentPath .. name) then
          fs.makeDir(currentPath .. name)
          menu = false
        else
          window({"Couldn't create folder", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 6 then
        window({"Create new file:"})
        term.setCursorPos(x, y + 1)
        local name = read()
        
        if not fs.exists(currentPath .. name) then
          shell.run("edit", currentPath .. name)
          menu = false
        else
          window({"Couldn't create file", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 7 then
        if selected then
          window({"Delete " .. selected .. "?"})
          term.setCursorPos(x, y + 1)
          local selection = selectionMenu({"No", "Yes"})
          
          if selection == 2 then
            fs.delete(currentPath .. selected)
            window({"Deleted " .. selected, "", "Press any key"})
            os.pullEvent("key")
            menu = false
          end
        else
          window({"Choose a file first", "", "Press any key"})
          os.pullEvent("key")
          menu = false
        end
      elseif selection == 8 then
        closeSides()
        window({"All modems closed", "", "Press any key"})
        os.pullEvent("key")
      elseif selection == 9 then
        window({"Use mouse or arrow keys", "to navigate the browser.", "Press [M] or right mouse", "button for menu.", "", "Press any key"})
        os.pullEvent("key")
      elseif selection == 11 then
        menu = false
      end
    else
      drawFrame()
      writeText("RedFile " .. version .. " | Press [M] for menu | ID: " .. os.getComputerID(), nil, nil, x, y)
      writeText("Current path: " .. currentPath, nil, nil, x, y + 1)
      term.setCursorPos(x, y + 3)
      selection, menu = selectionMenu(fileList, keys.m, h - 5)
      
      if not menu then
        if selection == 1 then
          currentPath = back(currentPath)
        elseif selection == #fileList then
          running = false
        else
          selected = fileList[selection]
          
          if not fs.isDir(currentPath .. selected) then
            menu = true
          else
            currentPath = currentPath .. selected
          end
        end
      else
        if selection ~= 1 and selection ~= #fileList then
          selected = fileList[selection]
        else
          selected = nil
        end
      end
    end
  end
end

closeSides()

reset()