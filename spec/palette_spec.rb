require_relative '../lib/dunmanifestin/palette'
require_relative '../lib/dunmanifestin/genre'

describe Palette do
  it 'has a name, which is the string after the pipe' do
    p = Palette.new(<<-EOF, 'characters.pal')
|person
Hamlet
    EOF

    expect(p.name).to eq 'person'
  end

  it 'defaults its name to the base name of the palette file' do
    p = Palette.new(<<-EOF, '/foo/bar/characters.pal')
Hamlet
    EOF
    expect(p.name).to eq 'characters'
  end

  it 'ignores extra whitespace before the title' do
    p = Palette.new(<<-EOF, '/foo/bar/characters.pal')


|person
Hamlet
    EOF

    expect(p.name).to eq 'person'
  end

  it 'selects a phrase at random' do
    palette = Palette.new(<<-EOF, 'characters.pal')
|person
Hamlet
Ophelia
    EOF

    selections = 50.times.map { palette.sample nil }
    expect(selections).to include 'Hamlet'
    expect(selections).to include 'Ophelia'
  end

  it 'excludes the population suffix from its name' do
    palette = Palette.new(<<-EOF, 'characters.pal')
|person*1
Hamlet
    EOF
    expect(palette.name).to eq 'person'
  end

  it 'limits the population of unique phrase renderings' do
    syllable = Palette.new(<<-EOF, 'characters.pal')
|syllable
a
thi
ga
i
hi
    EOF
    person = Palette.new(<<-EOF, 'characters.pal')
|person*1
[syllable][syllable][syllable][syllable]
    EOF

    genre = Genre.new([syllable, person])
    character = Phrase.new('[person:recur]')
    characters = 50.times.map { character.reify genre }
    expect(characters.uniq.length).to be < 20
  end

  it 'ignores comments' do
    palette = Palette.new(<<-EOF, 'characters.pal')
|person
// prince of Denmark
Hamlet
Ophelia // daughter of Polonius
    EOF

    selections = 50.times.map { palette.sample nil }
    expect(selections.uniq.sort).to eq ['Hamlet', 'Ophelia']
  end

  it 'ignores lines with only whitespace' do
    palette_text = "|person\n  \nErnie"
    palette = Palette.new(palette_text, 'characters.pal')
    selections = 50.times.map { palette.sample nil }
    expect(selections.uniq.sort).to eq ['Ernie']
  end

  it 'preserves blockquotes' do
    palette = Palette.new(<<-EOF, 'characters.pal')
|person
>>
# Hamlet

Prince of Denmark
<<
>>
# Ophelia

Daughter of Polonius
<<
Zack
Zed

    EOF

    selections = 50.times.map { palette.sample nil }
    expect(selections.uniq.sort).to eq [
      "# Hamlet\n\nPrince of Denmark",
      "# Ophelia\n\nDaughter of Polonius",
      "Zack",
      "Zed"
    ]

  end

  it 'ignores empty lines' do
    palette_text = "|person\n\n\nBert\n\n"
    palette = Palette.new(palette_text, 'characters.pal')
    selections = 50.times.map { palette.sample nil }
    expect(selections.uniq.sort).to eq ['Bert']
  end

  it 'allows shorthand for duplicate elements' do
    palette = Palette.new(<<-EOF, 'tropes.pal')
|trope
5@loose cannon rookie cop
rogue whac-a-mole game terrorizing Boston
    EOF

    selections = 100.times.map { palette.sample nil }
    expect(selections.select { |s| s == 'loose cannon rookie cop' }.length).to be > 70
    expect(selections).to include 'rogue whac-a-mole game terrorizing Boston'
  end
end
