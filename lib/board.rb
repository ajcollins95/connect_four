class Board
  attr_reader :columns
  def initialize
    @width = 7
    @height = 6
    @columns = Array.new
    (0...@width).each do |i| @columns.push(Column.new(i)) end
  end

  def check_win(col)
    root = last_placed(col)
    adj = root.adj_matches
    if adj.length > 0
      connect_fours = 0
      adj.each { |slot,dir| connect_fours += 1 if root.check_line(dir) }
      return connect_fours > 0
    else
      return false
    end
  end


  def last_placed(col)
    #gets the slot that was placed last in the column
    i = @height - 1
    @columns[col].col_slots.each_with_index { |slot,index|
      last = @columns[col].col_slots[index-1]
      #sets the found index to wherever the column changes from filled to empty
      i = index-1 if slot.status.to_i == 0 && last.status.to_i > 0
    }
    return @columns[col].col_slots[i]
  end

end

class Column
  attr_reader :col_slots
  def initialize(x)
    #columns:
    #know which column they are (col)
    #knows which slots are in itself by their row (col_slots)
    @col = x
    height = 6
    @col_slots = Array.new(height)
    (0...height).each do |y| @col_slots[y] = Slot.new(x,y) end
  end

  def place(player)
    #tries to place a piece in the column
    placed = false
    @col_slots.each do |s|
      if s.status == 0
        s.fill(player)
        placed = true
        break
      end
    end
    return placed
  end

end

class Slot
  attr_reader :pos, :status
  @@slots =[]

  def initialize(x,y)
    #Slots: know which slots have been made
    #know their position (pos)
    #knows what they contain (status)
    @pos = [x,y]
    @status = 0
    @@slots.push(self)
  end

  def adj_matches
    #returns hash of k=adjMatchedSlot, v=(dir to get there)
    dirs = [[+1,0],[+1,-1],[0,-1],[-1,-1],[-1,0],[-1,+1],[0,+1],[+1,+1]]
    height,width = 6,7
    matches = Hash.new
    dirs.each do |dir| matches[[@pos[0]+dir[0],@pos[1]+dir[1]]] = dir end
    #matches key is the new location, val is dir it took to get there
    on_board = matches.select do |k,v|
      self.on_board(k)
    end
    adj_slots = Hash.new
    @@slots.each do |slot|
      if on_board.include?(slot.pos) && slot.status == self.status
        adj_slots[slot] = on_board[slot.pos]
      end
    end
    return adj_slots
  end

  def check_dir(dir)
    #gets directions where there's a match adjacent to root
    #checks a match for a connect four in a direction
    matches = 0
    player = @status
    node = self
    runs = 0
    until node.status != player || runs > 2
      runs += 1
      next_pos = node.advance(dir)
      @@slots.each do |slot|
        if next_pos == slot.pos
          matches += 1
          node = slot
        end
      end
      puts node.status != player
    end
    return matches
  end

  def check_line(dir)
    puts check_dir(dir)
    return false
  end

  def advance(dir)
    next_pos = [@pos[0]+dir[0],@pos[1]+dir[1]]
    if on_board(next_pos)
      return next_pos
    else
      return [-1,-1]
    end
  end

  def on_board(pos)
    height, width = 6,7
    return (0 <= pos[0] && pos[0] < width && 0 <= pos[1] && pos[1] < height)
  end

  def fill(player)
    @status = player
  end

  def slots
    @@slots
  end
end
