#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs title screen processing.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    if $BTEST
      battle_test
      return
    end
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    $game_system = Game_System.new
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    @menu_labels = ["New Game", "Continue", "Shutdown"]
    @menu_windows = []
    menu_w = 160
    menu_h = 56
    menu_margin = 24
    total_w = @menu_labels.size * menu_w + (@menu_labels.size - 1) * menu_margin
    start_x = 320 - total_w / 2
    y = 380
    for i in 0...@menu_labels.size
      win = Window_Base.new(start_x + i * (menu_w + menu_margin), y, menu_w, menu_h)
      win.opacity = 200
      win.back_opacity = 160
      win.contents = Bitmap.new(menu_w - 32, menu_h - 32)
      win.contents.font.color = Window_Base.new(0,0,0,0).normal_color
      win.contents.draw_text(0, 0, win.contents.width, win.contents.height, @menu_labels[i], 1)
      @menu_windows << win
    end
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    @menu_index = @continue_enabled ? 1 : 0
    refresh_menu_highlight
    $game_system.bgm_play($data_system.title_bgm)
    Audio.me_stop
    Audio.bgs_stop
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
    for win in @menu_windows
      win.dispose
    end
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    last_index = @menu_index
    moved = false
    if Input.repeat?(Input::RIGHT)
      @menu_index = (@menu_index + 1) % @menu_labels.size
      moved = true if @menu_index != last_index
    elsif Input.repeat?(Input::LEFT)
      @menu_index = (@menu_index - 1 + @menu_labels.size) % @menu_labels.size
      moved = true if @menu_index != last_index
    end
    if moved
      $game_system.se_play($data_system.cursor_se)
      refresh_menu_highlight
    end

    if Input.trigger?(Input::C)
      case @menu_index
      when 0
        command_new_game
      when 1
        command_continue
      when 2
        command_shutdown
      end
    end
  end

  def refresh_menu_highlight
    for i in 0...@menu_windows.size
      if i == @menu_index
        @menu_windows[i].contents.font.color = Window_Base.new(0,0,0,0).text_color(6)
      else
        @menu_windows[i].contents.font.color = Window_Base.new(0,0,0,0).normal_color
      end
      @menu_windows[i].contents.clear
      @menu_windows[i].contents.draw_text(0, 0, @menu_windows[i].contents.width, @menu_windows[i].contents.height, @menu_labels[i], 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Command: New Game
  #--------------------------------------------------------------------------
  def command_new_game
    $game_system.se_play($data_system.decision_se)
    Audio.bgm_stop
    Graphics.frame_count = 0
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $game_map.autoplay
    $game_map.update
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Command: Continue
  #--------------------------------------------------------------------------
  def command_continue
    unless @continue_enabled
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    $game_system.se_play($data_system.decision_se)
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # * Command: Shutdown
  #--------------------------------------------------------------------------
  def command_shutdown
    $game_system.se_play($data_system.decision_se)
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # * Battle Test
  #--------------------------------------------------------------------------
  def battle_test
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    Graphics.frame_count = 0
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    $game_party.setup_battle_test_members
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    $game_system.se_play($data_system.battle_start_se)
    $game_system.bgm_play($game_system.battle_bgm)
    $scene = Scene_Battle.new
  end
end