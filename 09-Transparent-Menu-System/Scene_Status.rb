#==============================================================================
# ** Window_StatusBasic
#------------------------------------------------------------------------------
#  This window displays basic character information (name, class, level, exp).
#==============================================================================

class Window_StatusBasic < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 64, 320, 200)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_graphic(@actor, 40, 112)
    if @actor.states.empty?
      self.contents.font.color = normal_color
      self.contents.draw_text(0, 0, 80, 32, "[Normal]", 1)
    else
      x = 8
      for state_id in @actor.states
        state = $data_states[state_id]
        if state != nil
          self.contents.font.color = normal_color
          self.contents.draw_text(x, 0, 100, 32, "[" + state.name + "]", 1)
          x += 110
        end
      end
    end
    
    draw_actor_name(@actor, 100, 0)
    draw_actor_class(@actor, 100, 32)
    draw_actor_level(@actor, 100, 64)

    self.contents.font.color = system_color
    self.contents.draw_text(100, 96, 80, 32, "EXP")
    self.contents.font.color = normal_color
    self.contents.draw_text(180, 96, 108, 32, @actor.exp_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(100, 128, 80, 32, "NEXT")
    self.contents.font.color = normal_color
    self.contents.draw_text(180, 128, 108, 32, @actor.next_rest_exp_s, 2)
  end
end

#==============================================================================
# ** Window_StatusVital
#------------------------------------------------------------------------------
#  This window displays HP and SP information.
#==============================================================================

class Window_StatusVital < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(320, 64, 320, 140)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 160, 32, "Vital Stats")
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 32, 40, 32, "HP")
    self.contents.font.color = normal_color
    hp_text = @actor.hp.to_s + " / " + @actor.maxhp.to_s
    self.contents.draw_text(4, 32, self.contents.width - 8, 32, hp_text, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 64, 40, 32, "SP")
    self.contents.font.color = normal_color
    sp_text = @actor.sp.to_s + " / " + @actor.maxsp.to_s
    self.contents.draw_text(4, 64, self.contents.width - 8, 32, sp_text, 2)
  end
end

#==============================================================================
# ** Window_StatusParameters
#------------------------------------------------------------------------------
#  This window displays character parameters (stats).
#==============================================================================

class Window_StatusParameters < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 264, 320, 216)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 160, 32, "Parameters")
    y = 32
    for i in 0..6
      draw_actor_parameter(@actor, 4, y, i)
      y += 32
    end
  end
end

#==============================================================================
# ** Window_StatusEquipment
#------------------------------------------------------------------------------
#  This window displays equipped items.
#==============================================================================

class Window_StatusEquipment < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(320, 204, 320, 276)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 160, 32, "Equipment")
    self.contents.font.color = system_color
    self.contents.draw_text(4, 40, 92, 32, $data_system.words.weapon)
    draw_item_name($data_weapons[@actor.weapon_id], 100, 40)

    y = 72
    armor_names = [$data_system.words.armor1, $data_system.words.armor2, 
                   $data_system.words.armor3, $data_system.words.armor4]
    armor_ids = [@actor.armor1_id, @actor.armor2_id, 
                 @actor.armor3_id, @actor.armor4_id]
    
    for i in 0..3
      self.contents.font.color = system_color
      self.contents.draw_text(4, y, 92, 32, armor_names[i])
      draw_item_name($data_armors[armor_ids[i]], 100, y)
      y += 32
    end
  end
end

#==============================================================================
# ** Window_StatusState
#------------------------------------------------------------------------------
#  This window displays character states and status effects.
#==============================================================================

class Window_StatusState < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    self.visible = false
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
  end
end

#==============================================================================
# ** Scene_Status
#------------------------------------------------------------------------------
#  This class performs status screen processing.
#==============================================================================

class Scene_Status
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    @actor = $game_party.actors[@actor_index]
    @help_window = Window_Help.new
    @help_window.set_text(@actor.name + "'s Status")
    
    @state_window = Window_StatusState.new(@actor)
    @basic_window = Window_StatusBasic.new(@actor)
    @vital_window = Window_StatusVital.new(@actor)
    @parameters_window = Window_StatusParameters.new(@actor)
    @equipment_window = Window_StatusEquipment.new(@actor)
    
    windows = [@help_window, @state_window, @basic_window, @vital_window, 
               @parameters_window, @equipment_window]
    windows.each do |window|
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
    @help_window.dispose
    @state_window.dispose
    @basic_window.dispose
    @vital_window.dispose
    @parameters_window.dispose
    @equipment_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    windows = [@help_window, @state_window, @basic_window, @vital_window,
               @parameters_window, @equipment_window]
    windows.each { |window| window.update }
    
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(3)
      return
    end
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Status.new(@actor_index)
      return
    end
    if Input.trigger?(Input::L)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end