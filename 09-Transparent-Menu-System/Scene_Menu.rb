#==============================================================================
# ** Window_CharacterStatus
#------------------------------------------------------------------------------
#  This window displays a single character's status on the menu screen.
#==============================================================================

class Window_CharacterStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, actor_index)
    super(x, y, 480, 120)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor_index = actor_index
    @item_max = 1
    self.active = false
    self.index = -1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @actor_index < $game_party.actors.size
      actor = $game_party.actors[@actor_index]
      draw_actor_graphic(actor, 24, 67)
      draw_actor_name(actor, 64, 0)
      
      self.contents.font.color = system_color
      self.contents.draw_text(64, 27, 24, 32, "Lv")
      self.contents.font.color = normal_color
      self.contents.draw_text(104, 27, 48, 32, actor.level.to_s, 0)

      self.contents.font.color = system_color
      self.contents.draw_text(64, 54, 24, 32, "E")
      self.contents.font.color = normal_color
      exp_text = actor.exp_s + " / " + actor.next_exp_s
      self.contents.draw_text(104, 54, 144, 32, exp_text, 0)
      draw_actor_state(actor, 270, 0)
      
      self.contents.font.color = system_color
      self.contents.draw_text(270, 27, 40, 32, "HP")
      self.contents.font.color = normal_color
      hp_text = actor.hp.to_s + " / " + actor.maxhp.to_s
      self.contents.draw_text(310, 27, 144, 32, hp_text)
      
      self.contents.font.color = system_color
      self.contents.draw_text(270, 54, 40, 32, "SP")
      self.contents.font.color = normal_color
      sp_text = actor.sp.to_s + " / " + actor.maxsp.to_s
      self.contents.draw_text(310, 54, 144, 32, sp_text)
    else
      self.contents.font.color = system_color
      self.contents.draw_text(0, 27, self.contents.width, 32, "Empty Slot", 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
    else
      self.cursor_rect.set(0, 0, self.width - 32, self.height - 32)
    end
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs menu screen processing.
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @status_index = 0
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    s1 = $data_system.words.item
    s2 = $data_system.words.skill
    s3 = $data_system.words.equip
    s4 = "Status"
    s5 = "Save Game"
    s6 = "Exit"
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.actors.size == 0
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
    end
    if $game_system.save_disabled
      @command_window.disable_item(4)
    end
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 224
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 320
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = 416
    @character_windows = []
    for i in 0...4
      x = 160
      y = i * 120
      @character_windows[i] = Window_CharacterStatus.new(x, y, i)
    end

    @command_window.opacity = 210
    @command_window.back_opacity = 170
    @playtime_window.opacity = 210
    @playtime_window.back_opacity = 170
    @steps_window.opacity = 210
    @steps_window.back_opacity = 170
    @gold_window.opacity = 210
    @gold_window.back_opacity = 170
    @character_windows.each do |window|
      window.opacity = 210
      window.back_opacity = 170
    end
    
    @map_sprite = Spriteset_Map.new
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      @map_sprite.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @map_sprite.dispose
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @character_windows.each { |window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @command_window.update
    @playtime_window.update
    @steps_window.update
    @gold_window.update
    @character_windows.each { |window| window.update }
    if @command_window.active
      update_command
      return
    end
    if @status_active
      update_status
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #--------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      if $game_party.actors.size == 0 and @command_window.index < 4
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      case @command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Item.new
      when 1
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @status_active = true
        @status_index = 0
        @character_windows[@status_index].active = true
        @character_windows[@status_index].index = 0
      when 2
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @status_active = true
        @status_index = 0
        @character_windows[@status_index].active = true
        @character_windows[@status_index].index = 0
      when 3
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @status_active = true
        @status_index = 0
        @character_windows[@status_index].active = true
        @character_windows[@status_index].index = 0
      when 4
        if $game_system.save_disabled
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Save.new
      when 5
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_End.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when character selection is active)
  #--------------------------------------------------------------------------
  def update_status
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @command_window.active = true
      @status_active = false
      @character_windows.each do |window|
        window.active = false
        window.index = -1
      end
      return
    end
    if Input.trigger?(Input::C)
      if @status_index >= $game_party.actors.size
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      case @command_window.index
      when 1
        if $game_party.actors[@status_index].restriction >= 2
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Skill.new(@status_index)
      when 2
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Equip.new(@status_index)
      when 3
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Status.new(@status_index)
      end
      return
    end
    if Input.repeat?(Input::DOWN)
      if @status_index < 3
        $game_system.se_play($data_system.cursor_se)
        @character_windows[@status_index].active = false
        @character_windows[@status_index].index = -1
        @status_index += 1
        @character_windows[@status_index].active = true
        @character_windows[@status_index].index = 0
      end
    elsif Input.repeat?(Input::UP)
      if @status_index > 0
        $game_system.se_play($data_system.cursor_se)
        @character_windows[@status_index].active = false
        @character_windows[@status_index].index = -1
        @status_index -= 1
        @character_windows[@status_index].active = true
        @character_windows[@status_index].index = 0
      end
    end
  end
end