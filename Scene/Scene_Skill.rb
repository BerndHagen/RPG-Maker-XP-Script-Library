#==============================================================================
# ** Window_SkillStat
#------------------------------------------------------------------------------
#  This window displays a single skill statistic.
#==============================================================================

class Window_SkillStat < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, label)
    super(x, y, width, 80)
    self.contents = Bitmap.new(width - 32, height - 32)
    @label = label
    @value = "—"
    @skill = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Skill
  #--------------------------------------------------------------------------
  def skill=(skill)
    if @skill != skill
      @skill = skill
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
    value_text = get_value_text
    self.contents.draw_text(4, 24, self.contents.width - 8, 24, value_text, 1)
  end
  #--------------------------------------------------------------------------
  # * Get Value Text
  #--------------------------------------------------------------------------
  def get_value_text
    return "—" if @skill == nil
    case @label
    when "Cost"
      return @skill.sp_cost.to_s + " SP"
    when "Accuracy"
      return @skill.hit.to_s + "%"
    when "Power"
      return @skill.power > 0 ? @skill.power.to_s : "—"
    when "Variance"
      return @skill.variance.to_s + "%"
    else
      return "—"
    end
  end
end

#==============================================================================
# ** Scene_Skill
#------------------------------------------------------------------------------
#  This class performs skill screen processing.
#==============================================================================

class Scene_Skill
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    @actor = $game_party.actors[@actor_index]
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    @skill_window.height = 272
    @skill_window.contents.dispose if @skill_window.contents
    @skill_window.contents = Bitmap.new(@skill_window.width - 32, (@skill_window.height - 32))
    @skill_window.refresh
    @skill_window.help_window = @help_window
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    window_width = 160
    @stat_windows = []
    @stat_windows[0] = Window_SkillStat.new(0, 400, window_width, "Cost")
    @stat_windows[1] = Window_SkillStat.new(160, 400, window_width, "Accuracy") 
    @stat_windows[2] = Window_SkillStat.new(320, 400, window_width, "Power")
    @stat_windows[3] = Window_SkillStat.new(480, 400, window_width, "Variance")
    
    [@help_window, @status_window, @skill_window, @target_window].each do |window|
      window.opacity = 210
      window.back_opacity = 170
    end

    @stat_windows.each do |window|
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
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
    @stat_windows.each { |window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    @stat_windows.each { |window| window.update }
    current_skill = @skill_window.skill
    @stat_windows.each { |window| window.skill = current_skill }
    
    if @skill_window.active
      update_skill
      return
    end
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (if skill window is active)
  #--------------------------------------------------------------------------
  def update_skill
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(1)
      return
    end
    if Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      if @skill.scope >= 3
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      else
        if @skill.common_event_id > 0
          $game_temp.common_event_id = @skill.common_event_id
          $game_system.se_play(@skill.menu_se)
          @actor.sp -= @skill.sp_cost
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          @stat_windows.each { |window| window.skill = @skill_window.skill }
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    if Input.trigger?(Input::L)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when target window is active)
  #--------------------------------------------------------------------------
  def update_target
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    if Input.trigger?(Input::C)
      unless @actor.skill_can_use?(@skill.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @target_window.index == -1
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      if @target_window.index <= -2
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      if @target_window.index >= 0
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      if used
        $game_system.se_play(@skill.menu_se)
        @actor.sp -= @skill.sp_cost
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        @stat_windows.each { |window| window.skill = @skill_window.skill }
        if $game_party.all_dead?
          $scene = Scene_Gameover.new
          return
        end
        if @skill.common_event_id > 0
          $game_temp.common_event_id = @skill.common_event_id
          $scene = Scene_Map.new
          return
        end
      end
      unless used
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end