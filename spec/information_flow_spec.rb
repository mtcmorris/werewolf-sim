require 'spec_helper'

require "./game"


describe "drawing conclusions from information" do
  let(:game) {
    Game.new players
  }

  describe "when the seer reveals themselves" do
    let(:players) {
      [
        Seer.new(strategy: AnyWerewolf),
        Villager.new,
        Werewolf.new
      ]
    }

    specify 'they condemn identified players' do
      players.last.identify!
      game.seer_reveals!

      expect(players.last).to be_condemned
    end

    specify 'they condemn themselves' do
      game.seer_reveals!
      expect(players.detect(&:seer?)).to be_condemned
    end
  end
end
