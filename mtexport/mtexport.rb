# line 1 "mtexport.rb.rl"
#!/usr/bin/env ruby

EntryBase = Struct.new(:author, :title, :status, :allow_comments, :basename,
  :convert_breaks, :allow_pings, :primary_category, :category, :date,
  :body, :extended_body, :excerpt, :keywords)

class Entry < EntryBase
  def setMetadata(key, value)
    case key
    when "AUTHOR"
      self.author = value
    when "TITLE"
      self.title = value
    when "STATUS"
      self.status = value
    when "ALLOW COMMENTS"
      self.allow_comments = (value == "0")
    when "CONVERT BREAKS"
      self.convert_breaks = value
    when "ALLOW PINGS"
      self.allow_pings = (value == "0")
    when "PRIMARY CATEGORY"
      self.primary_category = value
    when "CATEGORY"
      self.category = value
    when "DATE"
      self.date = value
    when "BODY"
      self.body = value
    when "EXTENDED BODY"
      self.extended_body = value
    when "EXCERPT"
      self.excerpt = value
    when "KEYWORDS"
      self.keywords = value
    end
  end

  def output_meta(key, value)
    if (!value.nil?)
      puts "#{key}: #{value}"
    end
  end

  def output_meta_bool(key, value)
    output_meta(key, value ? "1" : "0")
  end
  
  def output_multi(key, value)
    puts "#{key}:"
    value = "" if value.nil?
    puts "#{value}\n"
    puts "-----"
  end

  def to_export
    output_meta("AUTHOR", self.author)
    output_meta("TITLE", self.title)
    output_meta("BASENAME", self.basename)
    output_meta_bool("ALLOW COMMENTS", self.allow_comments)
    output_meta("CONVERT BREAKS", self.convert_breaks)
    output_meta_bool("ALLOW PINGS", self.allow_pings)
    output_meta("PRIMARY CATEGORY", self.primary_category)
    output_meta("CATEGORY", self.category)
    output_meta("DATE", self.date)
    puts "-----"
    output_multi("BODY", self.body)
    output_multi("EXTENDED BODY", self.extended_body)
    output_multi("EXCERPT", self.excerpt)
    output_multi("KEYWORDS", self.keywords)
    puts
    puts
    puts "--------"
  end
  
  def adjust_basename
    basename = self.title.dup
    if self.keywords =~ /([^\]]*) \s* \[ ([^\]]+) \] \s* ([^\]]*)/x
      basename = $2
      self.keywords = $1 + $3
    end
    basename.gsub!(" ", "_")
    basename.gsub!(/[.\',\!\-]/, "")
    basename.tr!('A-Z', 'a-z')
    self.basename = basename
  end
end

# line 148 "mtexport.rb.rl"


class MTExportParser
  def initialize
    
# line 97 "mtexport.rb"
class << self
	attr_accessor :_mtExportScanner_actions
	private :_mtExportScanner_actions, :_mtExportScanner_actions=
end
self._mtExportScanner_actions = [
	0, 1, 0, 1, 1, 1, 7, 2, 
	5, 1, 2, 7, 2, 2, 7, 3, 
	2, 7, 6, 3, 4, 5, 1, 3, 
	7, 5, 1, 4, 4, 7, 5, 1
]

class << self
	attr_accessor :_mtExportScanner_key_offsets
	private :_mtExportScanner_key_offsets, :_mtExportScanner_key_offsets=
end
self._mtExportScanner_key_offsets = [
	0, 0, 8, 9, 15, 16, 18, 19, 
	20, 21, 22, 23, 25, 31, 34, 35, 
	36, 37, 38, 39, 40, 41, 42, 44, 
	45, 46, 47, 48, 49, 51, 54, 56, 
	57, 60, 63, 66, 69, 71, 72, 73, 
	74, 76, 77, 78, 79, 80, 81, 82, 
	83, 84, 85, 86, 87, 88, 89, 90, 
	91, 92, 93, 94, 95
]

class << self
	attr_accessor :_mtExportScanner_trans_keys
	private :_mtExportScanner_trans_keys, :_mtExportScanner_trans_keys=
end
self._mtExportScanner_trans_keys = [
	10, 13, 32, 45, 65, 90, 97, 122, 
	10, 32, 58, 65, 90, 97, 122, 32, 
	10, 13, 10, 45, 45, 45, 45, 10, 
	13, 10, 13, 45, 66, 69, 75, 10, 
	13, 45, 10, 45, 45, 45, 45, 45, 
	45, 45, 10, 13, 10, 79, 68, 89, 
	58, 10, 13, 10, 13, 45, 10, 13, 
	10, 10, 13, 45, 10, 13, 45, 10, 
	13, 45, 10, 13, 45, 10, 13, 10, 
	10, 88, 67, 84, 69, 82, 80, 84, 
	69, 78, 68, 69, 68, 32, 66, 69, 
	89, 87, 79, 82, 68, 83, 10, 10, 
	13, 32, 45, 65, 90, 97, 122, 0
]

class << self
	attr_accessor :_mtExportScanner_single_lengths
	private :_mtExportScanner_single_lengths, :_mtExportScanner_single_lengths=
end
self._mtExportScanner_single_lengths = [
	0, 4, 1, 2, 1, 2, 1, 1, 
	1, 1, 1, 2, 6, 3, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 2, 3, 2, 1, 
	3, 3, 3, 3, 2, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 4
]

class << self
	attr_accessor :_mtExportScanner_range_lengths
	private :_mtExportScanner_range_lengths, :_mtExportScanner_range_lengths=
end
self._mtExportScanner_range_lengths = [
	0, 2, 0, 2, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 2
]

class << self
	attr_accessor :_mtExportScanner_index_offsets
	private :_mtExportScanner_index_offsets, :_mtExportScanner_index_offsets=
end
self._mtExportScanner_index_offsets = [
	0, 0, 7, 9, 14, 16, 19, 21, 
	23, 25, 27, 29, 32, 39, 43, 45, 
	47, 49, 51, 53, 55, 57, 59, 62, 
	64, 66, 68, 70, 72, 75, 79, 82, 
	84, 88, 92, 96, 100, 103, 105, 107, 
	109, 112, 114, 116, 118, 120, 122, 124, 
	126, 128, 130, 132, 134, 136, 138, 140, 
	142, 144, 146, 148, 150
]

class << self
	attr_accessor :_mtExportScanner_indicies
	private :_mtExportScanner_indicies, :_mtExportScanner_indicies=
end
self._mtExportScanner_indicies = [
	0, 2, 3, 4, 3, 3, 1, 0, 
	1, 3, 5, 3, 3, 1, 6, 1, 
	8, 9, 7, 8, 1, 10, 1, 11, 
	1, 12, 1, 13, 1, 14, 15, 1, 
	16, 17, 18, 19, 20, 21, 1, 16, 
	17, 18, 1, 16, 1, 22, 1, 23, 
	1, 24, 1, 25, 1, 26, 1, 27, 
	1, 28, 1, 29, 30, 1, 29, 1, 
	31, 1, 32, 1, 33, 1, 34, 1, 
	35, 36, 1, 38, 39, 40, 37, 38, 
	39, 37, 41, 1, 38, 39, 42, 37, 
	38, 39, 43, 37, 38, 39, 44, 37, 
	38, 39, 45, 37, 46, 47, 37, 46, 
	1, 35, 1, 48, 1, 49, 50, 1, 
	51, 1, 52, 1, 53, 1, 33, 1, 
	54, 1, 55, 1, 56, 1, 57, 1, 
	58, 1, 59, 1, 19, 1, 60, 1, 
	61, 1, 62, 1, 63, 1, 64, 1, 
	65, 1, 33, 1, 14, 1, 0, 2, 
	3, 4, 3, 3, 1, 0
]

class << self
	attr_accessor :_mtExportScanner_trans_targs_wi
	private :_mtExportScanner_trans_targs_wi, :_mtExportScanner_trans_targs_wi=
end
self._mtExportScanner_trans_targs_wi = [
	1, 0, 2, 3, 7, 4, 5, 5, 
	1, 6, 8, 9, 10, 11, 12, 59, 
	13, 14, 15, 24, 39, 52, 16, 17, 
	18, 19, 20, 21, 22, 60, 23, 25, 
	26, 27, 28, 29, 38, 30, 29, 31, 
	32, 29, 33, 34, 35, 36, 12, 37, 
	40, 41, 45, 42, 43, 44, 46, 47, 
	48, 49, 50, 51, 53, 54, 55, 56, 
	57, 58
]

class << self
	attr_accessor :_mtExportScanner_trans_actions_wi
	private :_mtExportScanner_trans_actions_wi, :_mtExportScanner_trans_actions_wi=
end
self._mtExportScanner_trans_actions_wi = [
	5, 0, 0, 1, 0, 0, 0, 3, 
	10, 0, 0, 0, 0, 0, 5, 0, 
	5, 0, 0, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 16, 0, 1, 
	1, 1, 0, 5, 0, 3, 27, 19, 
	7, 23, 7, 7, 7, 7, 13, 0, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1
]

class << self
	attr_accessor :mtExportScanner_start
end
self.mtExportScanner_start = 60;
class << self
	attr_accessor :mtExportScanner_first_final
end
self.mtExportScanner_first_final = 60;
class << self
	attr_accessor :mtExportScanner_error
end
self.mtExportScanner_error = 0;

class << self
	attr_accessor :mtExportScanner_en_main
end
self.mtExportScanner_en_main = 60;

# line 153 "mtexport.rb.rl"
    # %%
    
# line 269 "mtexport.rb"
begin
	 @cs = mtExportScanner_start
end
# line 155 "mtexport.rb.rl"
    # %%
    
    @curline = 0
    @key = ""
    @value = ""
    @charsToDelete = 0
    @entries = []
    @current_entry = Entry.new
  end
  
  def execute(data)
    p = 0
    pe = data.length
    @data = data
    
    
# line 290 "mtexport.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	if p != pe
	if  @cs != 0
	while true
	_break_resume = false
	begin
	_break_again = false
	_keys = _mtExportScanner_key_offsets[ @cs]
	_trans = _mtExportScanner_index_offsets[ @cs]
	_klen = _mtExportScanner_single_lengths[ @cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if  @data[p] < _mtExportScanner_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif  @data[p] > _mtExportScanner_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _mtExportScanner_range_lengths[ @cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if  @data[p] < _mtExportScanner_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif  @data[p] > _mtExportScanner_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _mtExportScanner_indicies[_trans]
	 @cs = _mtExportScanner_trans_targs_wi[_trans]
	break if _mtExportScanner_trans_actions_wi[_trans] == 0
	_acts = _mtExportScanner_trans_actions_wi[_trans]
	_nacts = _mtExportScanner_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _mtExportScanner_actions[_acts - 1]
when 0:
# line 93 "mtexport.rb.rl"
		begin
 @key << data[p].chr; 		end
# line 93 "mtexport.rb.rl"
when 1:
# line 94 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 94 "mtexport.rb.rl"
when 2:
# line 95 "mtexport.rb.rl"
		begin

    @current_entry.setMetadata(@key, @value)
    @key = ""
    @value = ""
  		end
# line 95 "mtexport.rb.rl"
when 3:
# line 100 "mtexport.rb.rl"
		begin

    @value = @value.slice(0, @value.length - @charsToDelete)
    @current_entry.setMetadata(@key, @value)
    # puts "#{@key} = <#{@value}>\n"
    @charsToDelete = 0;
    @key = ""
    @value = ""
  		end
# line 100 "mtexport.rb.rl"
when 4:
# line 108 "mtexport.rb.rl"
		begin
 @charsToDelete = 0 		end
# line 108 "mtexport.rb.rl"
when 5:
# line 109 "mtexport.rb.rl"
		begin
 @charsToDelete += 1 		end
# line 109 "mtexport.rb.rl"
when 6:
# line 110 "mtexport.rb.rl"
		begin

    @entries << @current_entry
    @current_entry = Entry.new
  		end
# line 110 "mtexport.rb.rl"
when 7:
# line 115 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 115 "mtexport.rb.rl"
# line 412 "mtexport.rb"
		end # action switch
	end
	end while false
	break if _break_resume
	break if  @cs == 0
	p += 1
	break if p == pe
	end
	end
	end
	end
# line 171 "mtexport.rb.rl"
    # %%
    
    if @cs == mtExportScanner_error
      return -1
    elsif @cs >= mtExportScanner_first_final
      return 1
    else
      return 0
    end
  end
  
  def finish
    
# line 438 "mtexport.rb"
# line 184 "mtexport.rb.rl"
    # %%
  end
  
  def bump_line
    @curline += 1
    # puts @curline
  end
  
  def parse(stream)
    done = false
    bytes = 0;
    while (!done)
      data = stream.read(65536);
      if (!data.nil?)
        result = self.execute(data)
        if result < 0
          puts "Scanner result: #{result}"
          break
        end
      else
        done = true
      end
    end
    puts "Bytes: #{bytes}"
  end
  
  def print_summary
    puts "Number of lines: #{@curline}"
    # @entries[0].to_export
    @entries.each do |e|
      e.adjust_basename
      e.to_export
    end
  end
end

if __FILE__ == $0
  parser = MTExportParser::new
  parser.parse($stdin)
  parser.print_summary
end