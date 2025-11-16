#!/bin/bash

# generate_sounds.sh
# Script to generate placeholder sound files for tic-tac-toe game
# Requires afconvert (built-in on macOS)

echo "🔊 Generating placeholder sound files for tic-tac-toe..."
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script requires macOS for afconvert"
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
OUTPUT_DIR="$(pwd)/Sounds"

echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to generate a simple tone using sox (if available) or instructions
generate_tone() {
    local filename=$1
    local duration=$2
    local frequency=$3
    local description=$4
    
    echo "Creating: $filename ($description)"
    echo "  Duration: ${duration}s, Frequency: ${frequency}Hz"
    
    # Check if sox is available for tone generation
    if command -v sox &> /dev/null; then
        # Generate with sox
        sox -n -r 44100 -c 1 "$TEMP_DIR/${filename%.caf}.wav" synth $duration sine $frequency fade 0.01 $duration 0.01
        afconvert -f caff -d LEI16 "$TEMP_DIR/${filename%.caf}.wav" "$OUTPUT_DIR/$filename"
        echo "  ✅ Generated with sox"
    else
        echo "  ⚠️  sox not installed - will use system sounds"
        echo "     To install sox: brew install sox"
    fi
    
    echo ""
}

# Generate each sound file
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

generate_tone "turn_play.caf" 0.1 800 "Quick turn tap"
generate_tone "game_win.caf" 0.7 "523 659 784" "Winning chord (C-E-G)"
generate_tone "game_draw.caf" 0.4 400 "Draw tone"
generate_tone "game_reset.caf" 0.05 1000 "Reset click"

# Cleanup
rm -rf "$TEMP_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v sox &> /dev/null; then
    echo "✅ Sound files generated in: $OUTPUT_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Drag the files from $OUTPUT_DIR into Xcode"
    echo "2. Ensure 'Copy items if needed' is checked"
    echo "3. Add to all relevant targets"
    echo "4. Build and run to test"
else
    echo "ℹ️  To generate custom sound files, you have options:"
    echo ""
    echo "Option 1: Install sox and run this script again"
    echo "  brew install sox"
    echo "  ./generate_sounds.sh"
    echo ""
    echo "Option 2: Create your own sounds with audio software:"
    echo "  - GarageBand (free on Mac)"
    echo "  - Logic Pro"
    echo "  - Audacity (free, open source)"
    echo "  - Online sound generators"
    echo ""
    echo "Option 3: Find free sound effects online:"
    echo "  - freesound.org"
    echo "  - zapsplat.com"
    echo "  - soundbible.com"
    echo ""
    echo "Then convert to .caf format:"
    echo "  afconvert -f caff -d LEI16 input.wav output.caf"
    echo ""
    echo "Until custom files are added, the app will use system sounds."
fi

echo ""
echo "📖 See SOUND_SYSTEM_GUIDE.md for detailed instructions"
echo ""
