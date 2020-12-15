class Computer
  def initialize (filename)
    @data = File.readlines(filename, chomp: true)
    @mem = Hash.new(0)
  end

  def simulate
    @data.each do |line|
      case line
      when /mask = (\w+)/
        mask($1)
      else
        mem_access(line)
      end
    end
  end

  def answer
    @mem.values.sum
  end
end

class Computer1 < Computer
  def initialize (filename)
    super(filename)
    @on = nil
    @off = nil
  end

  def mask (bits)
    @on = bits.gsub('X', '0').to_i(2)
    @off = bits.gsub('X', '1').to_i(2)
  end

  def mem_access (line)
    addr, val = line.scan(/\d+/).map(&:to_i)
    @mem[addr] = (val | @on) & @off
  end
end

class Computer2 < Computer
  def initialize (filename)
    super(filename)
    @mask = nil
  end

  def mask(bits)
    @mask = bits
  end

  def update(addr, val, index)
    if index == addr.length
      @mem[addr] = val
      return
    end
    case @mask[index]
    when '0' # leave address alone
      update(addr, val, index + 1)
    when '1' # set bit to one
      addr[index] = '1'
      update(addr, val, index + 1)
    when 'X' # try both!
      addr[index] = '0'
      update(addr, val, index + 1)
      addr[index] = '1'
      update(addr, val, index + 1)
    end
  end

  def mem_access (line)
    addr, val = line.scan(/\d+/).map(&:to_i)
    addr = addr.to_s(2).rjust(36, '0')
    update(addr, val, 0)
  end

end

c1 = Computer1.new (ARGF.filename)
c1.simulate
p c1.answer

c2 = Computer2.new (ARGF.filename)
c2.simulate
p c2.answer
