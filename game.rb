require 'pry'
class Villager
  def role_prevents_lynching?
    false
  end

  def werewolf?
    false
  end

  def seer?
    false
  end
end

class Seer < Villager
  def initialize(strategy:)
    @strategy = strategy
    @identified_players = []
  end

  def role_prevents_lynching?
    true
  end

  def identify_randomly(players)
    identified_player = (players - @identified_players - [self]).sample

    # We may have identified everyone...
    if identified_player
      @identified_players.push identified_player
    end
  end

  def identified_werewolfs(active_players)
    active_players.select{|p|
      @identified_players.select(&:werewolf?).include?(p)
    }
  end

  def identified_villagers(active_players)
    active_players.select{|p|
      @identified_players.reject(&:werewolf?).include?(p)
    }
  end

  def seer?
    true
  end

  def should_reveal?(players)
    @strategy.should_reveal?(self, players)
  end
end

class AnyWerewolf
  def self.should_reveal?(seer, players)
    return true if seer.identified_werewolfs(players).any?
    return true if seer.identified_villagers(players).count > (players.count / 2)
    # seer.identified_werewolfs(players).count >= (players.select(&:werewolf?).count / 4) ||

  end
end


class Hunter < Villager
  def role_prevents_lynching?
    true
  end
end

class Cupid < Villager
  def role_prevents_lynching?
    true
  end
end

class Werewolf < Villager
  def werewolf?
    true
  end
end

class Game
  def initialize(werewolf_count:, villager_count:, seer_strategy:)
    @players = []
    # A condemned villager has revealed their role and should be
    # eaten next turn
    @condemned_villagers = []

    # A condemned werewolf has been revealed by the seer and should
    # be lynched next turn
    @condemned_werewolfs = []
    werewolf_count.times do
      @players << Werewolf.new
    end

    villager_count -= 1
    @players << Seer.new(strategy: seer_strategy)

    villager_count -= 2
    @players << Hunter.new
    @players << Hunter.new
    villager_count -= 1
    @players << Cupid.new

    villager_count.times do
      @players << Villager.new
    end
  end

  def run
    while !game_over? do
      eat_a_villager
      identify_someone if seer
      if @dead_this_round.is_a?(Hunter)
        lynch_someone(hunter_killing: true)
      end
      seer_reveals! if seer && seer.should_reveal?(@players)
      lynch_someone
    end

    @outcome
  end

  def werewolfs
    @players.select(&:werewolf?)
  end

  def villagers
    @players.reject(&:werewolf?)
  end

  def seer
    @players.detect(&:seer?)
  end

  def seer_reveals!
    @condemned_villagers += seer.identified_villagers(@players)
    @condemned_werewolfs += seer.identified_werewolfs(@players)

    @condemned_villagers = [seer] + @condemned_villagers
    @condemned_villagers.uniq!
  end

  def eat_a_villager
    eaten_villager = @condemned_villagers.shift || villagers.sample

    @dead_this_round = eaten_villager

    @players = @players - [eaten_villager]
  end

  def identify_someone
    seer.identify_randomly(@players)
  end

  def lynch_someone(hunter_killing: false)
    lynched_person = @condemned_werewolfs.shift || (@players - @condemned_villagers).sample

    if !hunter_killing
      return if lynched_person.nil?

      if lynched_person.role_prevents_lynching?
        @condemned_villagers.push lynched_person
        lynched_person = (@players - [lynched_person]).sample
      end

      return if lynched_person.nil?

      if lynched_person.seer?
        seer_reveals!
      end
    end

    @players = @players - [lynched_person]
  end

  def game_over?
    if werewolfs.count >= villagers.count
      @outcome = :werewolf_win
    elsif @players.none?(&:werewolf?)
      @outcome = :villagers_win
    else
      false
    end
  end
end

outcome = {
  werewolf_win: 0,
  villagers_win: 0
}

10000.times do |t|
  outcome[Game.new(werewolf_count: 7, villager_count: 26, seer_strategy: AnyWerewolf).run] += 1
end

puts outcome.inspect

