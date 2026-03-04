#==============================================================================
# ** Window_BGMList
#------------------------------------------------------------------------------
#  This window displays the list of available BGM files.
#==============================================================================

class Window_BGMList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 64, 480, 336)
    @column_max = 1
    @bgm_list = []
    load_bgm_list
    @item_max = @bgm_list.size
    self.contents = Bitmap.new(width - 32, @item_max * 32) if @item_max > 0
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Load BGM List
  #--------------------------------------------------------------------------
  def load_bgm_list
    @bgm_list = [
      RPG::AudioFile.new("001-Battle01", 100, 100),
      RPG::AudioFile.new("002-Battle02", 100, 100),
      RPG::AudioFile.new("003-Battle03", 100, 100),
      RPG::AudioFile.new("004-Battle04", 100, 100),
      RPG::AudioFile.new("005-Boss01", 100, 100),
      RPG::AudioFile.new("006-Boss02", 100, 100),
      RPG::AudioFile.new("007-Boss03", 100, 100),
      RPG::AudioFile.new("008-Boss04", 100, 100),
      RPG::AudioFile.new("009-LastBoss01", 100, 100),
      RPG::AudioFile.new("010-LastBoss02", 100, 100),
      RPG::AudioFile.new("011-LastBoss03", 100, 100),
      RPG::AudioFile.new("012-Temple01", 100, 100),
      RPG::AudioFile.new("013-Theme02", 100, 100),
      RPG::AudioFile.new("014-Theme03", 100, 100),
      RPG::AudioFile.new("015-Theme04", 100, 100),
      RPG::AudioFile.new("016-Theme05", 100, 100),
      RPG::AudioFile.new("017-Theme06", 100, 100),
      RPG::AudioFile.new("018-Field01", 100, 100),
      RPG::AudioFile.new("019-Field02", 100, 100),
      RPG::AudioFile.new("020-Field03", 100, 100),
      RPG::AudioFile.new("021-Field04", 100, 100),
      RPG::AudioFile.new("022-Field05", 100, 100),
      RPG::AudioFile.new("023-Town01", 100, 100),
      RPG::AudioFile.new("024-Town02", 100, 100),
      RPG::AudioFile.new("025-Town03", 100, 100),
      RPG::AudioFile.new("026-Town04", 100, 100),
      RPG::AudioFile.new("027-Town05", 100, 100)
    ]
  end
  #--------------------------------------------------------------------------
  # * Get Current BGM
  #--------------------------------------------------------------------------
  def bgm
    return @bgm_list[@index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.clear
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    bgm = @bgm_list[index]
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, bgm.name, 0)
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    if @help_window != nil
      @help_window.set_text("Select a BGM to play with C button")
    end
  end
end

#==============================================================================
# ** Window_BGMInfo
#------------------------------------------------------------------------------
#  This window displays information about the selected BGM.
#==============================================================================

class Window_BGMInfo < Window_Base
  attr_accessor :selection_index, :editing_mode
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(480, 64, 160, 336)
    self.contents = Bitmap.new(width - 32, height - 32)
    @bgm = nil
    @selection_index = 0
    @editing_mode = false
    @window_active = false
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set BGM
  #--------------------------------------------------------------------------
  def bgm=(bgm)
    if @bgm != bgm
      @bgm = bgm
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Set Active
  #--------------------------------------------------------------------------
  def set_active(active)
    @window_active = active
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Active
  #--------------------------------------------------------------------------
  def is_active
    return @window_active
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @bgm != nil
      self.contents.font.color = system_color
      self.contents.draw_text(4, 0, self.contents.width - 8, 32, "BGM Info")
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 32, self.contents.width - 8, 32, "Format:")
      self.contents.draw_text(4, 64, self.contents.width - 8, 32, "OGG")
      self.contents.draw_text(4, 96, self.contents.width - 8, 32, "Volume:")
      self.contents.draw_text(4, 160, self.contents.width - 8, 32, "Pitch:")
      
      if @editing_mode && @selection_index == 0
        self.contents.font.color = text_color(3)
      elsif @window_active && @selection_index == 0
        self.contents.font.color = text_color(6)
      else
        self.contents.font.color = normal_color
      end
      self.contents.draw_text(4, 128, self.contents.width - 8, 32, @bgm.volume.to_s + "%")
      if @editing_mode && @selection_index == 1
        self.contents.font.color = text_color(3)
      elsif @window_active && @selection_index == 1
        self.contents.font.color = text_color(6)
      else
        self.contents.font.color = normal_color
      end
      self.contents.draw_text(4, 192, self.contents.width - 8, 32, @bgm.pitch.to_s + "%")
    end
  end
end

#==============================================================================
# ** Window_BGMControls
#------------------------------------------------------------------------------
#  This window displays BGM control options.
#==============================================================================

class Window_BGMControls < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, 80)
    self.contents = Bitmap.new(width - 32, height - 32)
    @label = ""
    @info = ""
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Info
  #--------------------------------------------------------------------------
  def set_info(label, info)
    if @label != label || @info != info
      @label = label
      @info = info
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, self.contents.width - 8, 24, @label, 1)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 24, self.contents.width - 8, 24, @info, 1)
  end
end

#==============================================================================
# ** Scene_Audio_BGM
#------------------------------------------------------------------------------
#  This class performs BGM selection screen processing.
#==============================================================================

class Scene_Audio_BGM
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @in_info_window = false
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    @help_window = Window_Help.new
    @help_window.set_text("Select a BGM to play with C button")
    
    @bgm_window = Window_BGMList.new
    @bgm_window.help_window = @help_window
    @bgm_window.active = true
    
    @info_window = Window_BGMInfo.new
    @info_window.set_active(false)
    
    window_width = 160
    @control_windows = []
    @control_windows[0] = Window_BGMControls.new(0, 400, window_width)
    @control_windows[1] = Window_BGMControls.new(160, 400, window_width)
    @control_windows[2] = Window_BGMControls.new(320, 400, window_width)
    @control_windows[3] = Window_BGMControls.new(480, 400, window_width)
    
    @control_windows[0].set_info("Play", "C Button")
    @control_windows[1].set_info("Stop", "X Button")
    @control_windows[2].set_info("Navigate", "← → Keys")
    @control_windows[3].set_info("Back", "B Button")
    
    [@help_window, @bgm_window, @info_window].each do |window|
      window.opacity = 210
      window.back_opacity = 170
    end

    @control_windows.each do |window|
      window.opacity = 210
      window.back_opacity = 170
    end
    
    @background_sprite = Sprite.new
    @background_sprite.bitmap = RPG::Cache.title($data_system.title_name)
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
    @background_sprite.bitmap.dispose
    @background_sprite.dispose
    @help_window.dispose
    @bgm_window.dispose
    @info_window.dispose
    @control_windows.each { |window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @help_window.update
    @bgm_window.update
    @info_window.update
    @control_windows.each { |window| window.update }
    current_bgm = @bgm_window.bgm
    @info_window.bgm = current_bgm
    
    if @in_info_window
      update_info_selection
    else
      update_bgm_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (BGM Selection)
  #--------------------------------------------------------------------------
  def update_bgm_selection
    if Input.trigger?(Input::RIGHT)
      @in_info_window = true
      @info_window.set_active(true)
      @bgm_window.active = false
      $game_system.se_play($data_system.cursor_se)
      return
    end
    
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Title.new
      return
    end
    
    if Input.trigger?(Input::C)
      bgm = @bgm_window.bgm
      if bgm != nil
        $game_system.se_play($data_system.decision_se)
        played = false
        [".ogg", ".mp3", ".wav", ".mid", ""].each do |ext|
          begin
            Audio.bgm_play("Audio/BGM/" + bgm.name + ext, bgm.volume, bgm.pitch)
            played = true
            break
          rescue
            next
          end
        end
        unless played
          $game_system.se_play($data_system.buzzer_se)
        end
      else
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
    
    if Input.trigger?(Input::X)
      $game_system.se_play($data_system.decision_se)
      Audio.bgm_stop
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (Info Selection)
  #--------------------------------------------------------------------------
  def update_info_selection
    if Input.trigger?(Input::LEFT)
      @in_info_window = false
      @info_window.set_active(false)
      @info_window.editing_mode = false
      @bgm_window.active = true
      $game_system.se_play($data_system.cursor_se)
      return
    end
    
    if !@info_window.editing_mode
      if Input.trigger?(Input::UP)
        @info_window.selection_index = (@info_window.selection_index - 1) % 2
        @info_window.refresh
        $game_system.se_play($data_system.cursor_se)
        return
      elsif Input.trigger?(Input::DOWN)
        @info_window.selection_index = (@info_window.selection_index + 1) % 2
        @info_window.refresh
        $game_system.se_play($data_system.cursor_se)
        return
      end
      if Input.trigger?(Input::C)
        @info_window.editing_mode = true
        @info_window.refresh
        $game_system.se_play($data_system.decision_se)
        return
      end
    else
      bgm = @bgm_window.bgm
      if bgm != nil
        if @info_window.selection_index == 0
          if Input.repeat?(Input::UP)
            if bgm.volume < 100
              bgm.volume = [bgm.volume + 5, 100].min
              @info_window.refresh
              $game_system.se_play($data_system.cursor_se)
            end
          elsif Input.repeat?(Input::DOWN)
            if bgm.volume > 0
              bgm.volume = [bgm.volume - 5, 0].max
              @info_window.refresh
              $game_system.se_play($data_system.cursor_se)
            end
          end
        else
          if Input.repeat?(Input::UP)
            if bgm.pitch < 150
              bgm.pitch = [bgm.pitch + 5, 150].min
              @info_window.refresh
              $game_system.se_play($data_system.cursor_se)
            end
          elsif Input.repeat?(Input::DOWN)
            if bgm.pitch > 50
              bgm.pitch = [bgm.pitch - 5, 50].max
              @info_window.refresh
              $game_system.se_play($data_system.cursor_se)
            end
          end
        end
      end

      if Input.trigger?(Input::C)
        @info_window.editing_mode = false
        @info_window.refresh
        $game_system.se_play($data_system.decision_se)
        return
      end
    end
    if Input.trigger?(Input::B)
      if @info_window.editing_mode
        @info_window.editing_mode = false
        @info_window.refresh
        $game_system.se_play($data_system.cancel_se)
      else
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Title.new
      end
      return
    end
  end
end