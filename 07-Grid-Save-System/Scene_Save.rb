#==============================================================================
# ** Scene_Save
#------------------------------------------------------------------------------
#  This class performs save screen processing.
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super("Which file would you like to save to?")
  end
  #--------------------------------------------------------------------------
  # * Decision Processing
  #--------------------------------------------------------------------------
  def on_decision(filename)
    $game_system.se_play($data_system.save_se)
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    if $game_temp.save_calling
      $game_temp.save_calling = false
      $scene = Scene_Map.new
      return
    end
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # * Cancel Processing
  #--------------------------------------------------------------------------
  def on_cancel
    $game_system.se_play($data_system.cancel_se)
    if $game_temp.save_calling
      $game_temp.save_calling = false
      $scene = Scene_Map.new
      return
    end
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # * Write Save Data
  #--------------------------------------------------------------------------
  def write_save_data(file)
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    Marshal.dump(characters, file)
    Marshal.dump(Graphics.frame_count, file)
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end

#==============================================================================
# * Scene_File
#------------------------------------------------------------------------------
#  This class performs load screen processing.
#==============================================================================
class Scene_File
  def initialize(help_text)
    @help_text = help_text
    @confirmation_mode = false
    @file_index = 0
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    @sprite.color.set(0, 0, 0, 100)
    
  @help_window = Window_Help.new
  @help_window.opacity = 200
  @help_window.back_opacity = 160
  @help_window.set_text(@help_text)

  windows_to_set = [@help_window, @command_window, @confirmation_window]
  windows_to_set.concat(@savefile_windows) if @savefile_windows
  windows_to_set.each do |w|
    next unless w
    w.opacity = 200 if w.respond_to?(:opacity=)
    w.back_opacity = 160 if w.respond_to?(:back_opacity=)
  end
    id
    @savefile_windows = []
    margin = 20
    window_width = (640 - margin * 3) / 2
    window_height = (480 - 64 - margin * 3) / 2
    
    for i in 0..3
      x_pos = (i % 2) * (window_width + margin) + margin
      y_pos = (i / 2) * (window_height + margin) + 64 + margin
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i), x_pos, y_pos, window_width, window_height))
    end
    
    @file_index = $game_temp.last_file_index
    
    @confirmation_window = Window_SaveFile.new(@file_index, make_filename(@file_index), 
                                              120, 100, 400, 200)
    @confirmation_window.visible = false
    
    @command_window = Window_Command.new(160, ["Load File", "Cancel"])
    @command_window.x = 240
    @command_window.y = 320
    @command_window.visible = false
    @command_window.active = false
    Graphics.transition
    
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    
    Graphics.freeze
    
    @sprite.dispose
    @help_window.dispose
    @confirmation_window.dispose
    @command_window.dispose
    for i in @savefile_windows
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @help_window.update
    
    if @confirmation_mode
      @confirmation_window.update
      @command_window.update
      update_confirmation
    else
      for i in 0..3
        if i == @file_index
          @savefile_windows[i].update_cursor_rect
        else
          @savefile_windows[i].cursor_rect.empty
        end
        @savefile_windows[i].update
      end
      update_file_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update - File Selection Mode
  #--------------------------------------------------------------------------
  def update_file_selection
    if Input.trigger?(Input::C)
      if self.is_a?(Scene_Save)
        $game_system.se_play($data_system.decision_se)
        enter_confirmation_mode
      else
        if FileTest.exist?(make_filename(@file_index))
          $game_system.se_play($data_system.decision_se)
          enter_confirmation_mode
        else
          $game_system.se_play($data_system.cancel_se)
        end
      end
      return
    end
    
    if Input.trigger?(Input::B)
      on_cancel
      return
    end
    
    if Input.repeat?(Input::DOWN)
      if Input.trigger?(Input::DOWN) or @file_index < 2
        $game_system.se_play($data_system.cursor_se)
        @file_index = (@file_index + 2) % 4
        return
      end
    end
    
    if Input.repeat?(Input::UP)
      if Input.trigger?(Input::UP) or @file_index >= 2
        $game_system.se_play($data_system.cursor_se)
        @file_index = (@file_index + 2) % 4
        return
      end
    end
    
    if Input.repeat?(Input::RIGHT)
      if Input.trigger?(Input::RIGHT) or @file_index % 2 == 0
        $game_system.se_play($data_system.cursor_se)
        @file_index = (@file_index % 2 == 0) ? @file_index + 1 : @file_index - 1
        return
      end
    end
    
    if Input.repeat?(Input::LEFT)
      if Input.trigger?(Input::LEFT) or @file_index % 2 == 1
        $game_system.se_play($data_system.cursor_se)
        @file_index = (@file_index % 2 == 1) ? @file_index - 1 : @file_index + 1
        return
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update - Confirmation Mode
  #--------------------------------------------------------------------------
  def update_confirmation
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        on_decision(make_filename(@file_index))
        $game_temp.last_file_index = @file_index
        return
      when 1
        $game_system.se_play($data_system.cancel_se)
        exit_confirmation_mode
        return
      end
    end

    if Input.trigger?(Input::B)
      exit_confirmation_mode
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # * Enter Confirmation Mode
  #--------------------------------------------------------------------------
  def enter_confirmation_mode
    @confirmation_mode = true
    
    for window in @savefile_windows
      window.visible = false
    end
    
    @confirmation_window.dispose
    @confirmation_window = Window_SaveFile.new(@file_index, make_filename(@file_index), 120, 100, 400, 200)
    @confirmation_window.visible = true
    
    if self.is_a?(Scene_Save)
      if FileTest.exist?(make_filename(@file_index))
        @command_window = Window_Command.new(160, ["Save File", "Cancel"])
  @help_window.set_text("Overwrite this save file with your progress?")
      else
        @command_window = Window_Command.new(160, ["Save File", "Cancel"])
  @help_window.set_text("Save your progress to this save file?")
      end
    else
  @command_window = Window_Command.new(160, ["Load File", "Cancel"])
  @help_window.set_text("Load this save file and continue?")
    end
    windows_to_set = [@help_window, @command_window, @confirmation_window]
    windows_to_set.concat(@savefile_windows) if @savefile_windows
    windows_to_set.each do |w|
      next unless w
      w.opacity = 200 if w.respond_to?(:opacity=)
      w.back_opacity = 160 if w.respond_to?(:back_opacity=)
    end
    
    @command_window.x = 240
    @command_window.y = 320
    @command_window.visible = true
    @command_window.active = true
    @command_window.index = 0
  end
  
  #--------------------------------------------------------------------------
  # * Exit Confirmation Mode
  #--------------------------------------------------------------------------
  def exit_confirmation_mode
    $game_system.se_play($data_system.cancel_se)
    @confirmation_mode = false
    
    for window in @savefile_windows
      window.visible = true
    end
    
    @confirmation_window.visible = false
    @command_window.visible = false
    @command_window.active = false
    
    @help_window.set_text(@help_text)
  end
  
  #--------------------------------------------------------------------------
  # * Make File Name
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
end

#==============================================================================
# * Window_SaveFile
#==============================================================================
class Window_SaveFile < Window_Base
  attr_reader   :filename
  def initialize(file_index, filename, x = 0, y = 0, width = 640, height = 480)
    super(x, y, width, height)
    self.contents = Bitmap.new(width - 32, height - 32)
    @file_index = file_index
    @filename = filename
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    self.opacity = 200
    self.back_opacity = 160
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      @characters = Marshal.load(file)
      @frame_count = Marshal.load(file)
      @game_system = Marshal.load(file)
      @game_switches = Marshal.load(file)
      @game_variables = Marshal.load(file)
      file.close
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear if self.contents
    
    if @file_exist
      self.contents.font.color = normal_color
      name = "Save File #{@file_index + 1}"
      self.contents.draw_text(4, 0, self.contents.width, 32, name)
      @name_width = contents.text_size(name).width
      
      char_y = 42
      for i in 0...@characters.size
        bitmap = RPG::Cache.character(@characters[i][0], @characters[i][1])
        cw = bitmap.rect.width / 4
        ch = bitmap.rect.height / 4
        src_rect = Rect.new(0, 0, cw, ch)
        x = 10 + i * 40
        self.contents.blt(x, char_y, bitmap, src_rect) if char_y + ch < self.contents.height
      end
      hour = @frame_count / Graphics.frame_rate / 3600
      min = @frame_count / Graphics.frame_rate % 3600 / 60
      sec = @frame_count / Graphics.frame_rate % 60
      time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
      self.contents.font.color = normal_color
      if self.contents.height > 80
        self.contents.draw_text(4, self.contents.height - 64, self.contents.width - 8, 32, time_string, 2)
      end
      self.contents.font.color = normal_color
      time_string = @time_stamp.strftime("%Y/%m/%d %H:%M")
      if self.contents.height > 48
        self.contents.draw_text(4, self.contents.height - 32, self.contents.width - 8, 32, time_string, 2)
      end
    else
      self.contents.font.color = Color.new(128, 128, 128, 255)
      empty_text = "Empty File"
      self.contents.draw_text(4, 0, self.contents.width, 32, empty_text)
      @name_width = contents.text_size(empty_text).width
    end
  end
  #--------------------------------------------------------------------------
  # * Update Cursor Rectangle
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(0, 0, self.contents.width, 32)
  end
end