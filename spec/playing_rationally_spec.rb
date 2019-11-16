require 'spec_helper'

require "./game"


describe "playing rationally" do
  let(:game) {
    Game.new players
  }

  describe "rational lynching behaviour" do
    let(:players) {
      [
        Villager.new,
        Werewolf.new
      ]
    }

    context 'when all the remaining villagers have been condemned' do
      before do
        players.detect(&:villager?).condemn!
      end

      it "they should choose a werewolf" do
        expect(game.lynch_someone.werewolf?).to be true
      end
    end

    context 'when there is a known werewolf' do
      before do
        players.detect(&:werewolf?).condemn!
      end

      it "they should choose a werewolf" do
        expect(game.lynch_someone.werewolf?).to be true
      end
    end

    context 'when the remaining players are special roles' do
      let(:players) {
        [
          Seer.new(strategy: AnyWerewolf),
          Hunter.new,
          Werewolf.new,
          Cupid.new,
        ]
      }

      it "they should choose a werewolf" do
        expect(game.lynch_someone.werewolf?).to be true
      end
    end

    context 'when the remaining players are special roles' do
      let(:players) {
        [
          Seer.new(strategy: AnyWerewolf),
          Hunter.new,
          Werewolf.new,
          Cupid.new,
        ]
      }

      it "they should choose a werewolf" do
        expect(game.lynch_someone.werewolf?).to be true
      end
    end
  end
end