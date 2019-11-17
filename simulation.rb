require "./game"

outcome = {
  werewolf_win: 0,
  villagers_win: 0
}


10000.times do |t|
  @players = []
  3.times do
    @players << Werewolf.new
  end

  villager_count = 12
  @players << Seer.new(strategy: AnyWerewolf)

  @players << Hunter.new
  @players << Cupid.new

  (villager_count - 3).times do
    @players << Villager.new
  end

  outcome[Game.new(@players).run] += 1
end

puts outcome.inspect

