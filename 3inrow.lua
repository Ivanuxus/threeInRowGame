Game = {}

function Game:new()
    local obj = {
        board = {},
        size = 5,
        symbols = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:init()
    for i = 1, self.size do
        self.board[i] = {}
        for j = 1, self.size do
            self.board[i][j] = self.symbols[math.random(#self.symbols)]
        end
    end
    while(self:hasMatch()) do
        for i = 1, self.size do
            self.board[i] = {}
            for j = 1, self.size do
                self.board[i][j] = self.symbols[math.random(#self.symbols)]
            end
        end
    end
end


function Game:move(x, y, dir)
    local dx, dy = 0, 0
    if dir == "l" then dx = -1 end
    if dir == "r" then dx = 1 end
    if dir == "u" then dy = -1 end
    if dir == "d" then dy = 1 end

    local nx, ny = x + dx, y + dy

    if nx < 1 or nx > self.size or ny < 1 or ny > self.size then
        print("Неверный ход")
        return
    end
    -- print(self.board[y][x] .. " " .. self.board[ny][nx])

    self.board[y][x], self.board[ny][nx] = self.board[ny][nx], self.board[y][x]
    -- print(self.board[y][x] .. " " .. self.board[ny][nx])

    if not self:hasMatch() then
        self.board[y][x], self.board[ny][nx] = self.board[ny][nx], self.board[y][x]
        print("Ход не создал комбинаций, возвращаем обратно")
    else
        print("Успех")
        self:tick()
    end
end

function Game:hasMatch()
    for i = 1, self.size do
        for j = 1, self.size - 2 do
            if self.board[i][j] == self.board[i][j+1] and self.board[i][j] == self.board[i][j+2] then
                -- print(self.board[i][j])
                return true
            end
            if self.board[j][i] == self.board[j+1][i] and self.board[j][i] == self.board[j+2][i] then
                return true
            end
        end
    end
    return false
end

function Game:tick()
    local has_changes = true
    while has_changes do
        has_changes = false
        local matched = {}

        for y = 1, self.size do
            local count = 1
            for x = 2, self.size do
                if self.board[y][x] == self.board[y][x - 1] then
                    count = count + 1
                else
                    if count >= 3 then
                        has_changes = true
                        for k = x - count, x - 1 do
                            matched[y .. ":" .. k] = true
                        end
                    end
                    count = 1
                end
            end
            if count >= 3 then
                has_changes = true
                for k = self.size - count + 1, self.size do
                    matched[y .. ":" .. k] = true
                end
            end
        end

        for x = 1, self.size do
            local count = 1
            for y = 2, self.size do
                if self.board[y][x] == self.board[y - 1][x] then
                    count = count + 1
                else
                    if count >= 3 then
                        has_changes = true
                        for k = y - count, y - 1 do
                            matched[k .. ":" .. x] = true
                        end
                    end
                    count = 1
                end
            end
            if count >= 3 then
                has_changes = true
                for k = self.size - count + 1, self.size do
                    matched[k .. ":" .. x] = true
                end
            end
        end

        for key, _ in pairs(matched) do
            local y, x = key:match("(%d+):(%d+)")
            y = tonumber(y)
            x = tonumber(x)
            self.board[y][x] = nil
        end

        for x = 1, self.size do
            local empty_slots = {}
            for y = self.size, 1, -1 do
                if not self.board[y][x] then
                    table.insert(empty_slots, y)
                elseif #empty_slots > 0 then
                    local empty_y = table.remove(empty_slots, 1)
                    self.board[empty_y][x] = self.board[y][x]
                    self.board[y][x] = nil
                    table.insert(empty_slots, y)
                end
            end

            for _, y in ipairs(empty_slots) do
                self.board[y][x] = self.symbols[math.random(#self.symbols)]
            end
        end

        if has_changes then
            UI:dump(self.board)

        end
    end
end

function Game:hasPossibleMoves()
    for y = 1, self.size do
        for x = 1, self.size do

            if x < self.size then
                self.board[y][x], self.board[y][x+1] = self.board[y][x+1], self.board[y][x]
                if self:hasMatch() then
                    self.board[y][x], self.board[y][x+1] = self.board[y][x+1], self.board[y][x]
                    return true
                end
                self.board[y][x], self.board[y][x+1] = self.board[y][x+1], self.board[y][x]
            end


            if y < self.size then
                self.board[y][x], self.board[y+1][x] = self.board[y+1][x], self.board[y][x]
                if self:hasMatch() then
                    self.board[y][x], self.board[y+1][x] = self.board[y+1][x], self.board[y][x]
                    return true
                end
                self.board[y][x], self.board[y+1][x] = self.board[y+1][x], self.board[y][x]
            end
        end
    end
    return false
end

function Game:checkPotentialMatch(y, x)
    if x > 2 and self.board[y][x] and self.board[y][x-1] and self.board[y][x-2] and
       self.board[y][x] == self.board[y][x-1] and self.board[y][x] == self.board[y][x-2] then
        return true
    end
    if x < self.size - 1 and self.board[y][x] and self.board[y][x+1] and self.board[y][x+2] and
       self.board[y][x] == self.board[y][x+1] and self.board[y][x] == self.board[y][x+2] then
        return true
    end
    if y > 2 and self.board[y][x] and self.board[y-1][x] and self.board[y-2][x] and
       self.board[y][x] == self.board[y-1][x] and self.board[y][x] == self.board[y-2][x] then
        return true
    end
    if y < self.size - 1 and self.board[y][x] and self.board[y+1][x] and self.board[y+2][x] and
       self.board[y][x] == self.board[y+1][x] and self.board[y][x] == self.board[y+2][x] then
        return true
    end
    return false
end

function Game:mix()
    repeat
        for i = 1, self.size do
            for j = 1, self.size do
                self.board[i][j] = self.symbols[math.random(#self.symbols)]
            end
        end
    until not self:hasMatch() and self:hasPossibleMoves()
end

UI = {}

function UI:dump(board)
    print("  0 1 2 3 4 5 6 7 8 9")
    print("  - - - - - - - - - -")
    for i = 1, #board do
        io.write(i - 1 .. "|")
        for j = 1, #board[i] do
            io.write(board[i][j] .. " ")
        end
        print()
    end
end


local game = Game:new()
game:init()
UI:dump(game.board)

print("Введите ход (пример: m 0 0 r) или q, c для выхода")
while true do
    if not game:hasPossibleMoves() then
        print("Нет возможных ходов! Перемешиваем игровое поле")
        game:mix()
        UI:dump(game.board)
    end
    -- local cmd, x, y, d = io.read("*l"):match("(%w) (%d) (%d) (%w)")
    -- if cmd == "q" then break end
    local input = io.read("*l")
    local cmd, x, y, d = input:match("(%w) (%d) (%d) (%w)")

    if input == "q" or input == "c" then break end

    if cmd == "m" and x and y and d then
        game:move(tonumber(x) + 1, tonumber(y) + 1, d)
        if not game:hasPossibleMoves() then
            print("Нет возможных ходов! Перемешиваем игровое поле")
            game:mix()
            UI:dump(game.board)
        end
    end
end