# OBS Sim Sync

Displays live xRC Sim game data on livestream overlays via OBS Lua scripts.

To be used for competitions and tournaments in the Unity-based game [xRC Simulator](http://xrcsimulator.org/). Used in online [SRC events](https://secondrobotics.org).

## Setting up OBS

1. Open [OBS](https://obsproject.com/). Under Tools > Scripts, click the plus icon to add a Lua script. Browse and select "SimSync.lua".

2. Configure the script settings depending on how many servers you plan on using for your competition. Browse to select the directories that the game uses to output score data.

    * Use `/SET OUTPUT_SCORE_FILES=<directory>` as a spectator to set game output score files. Set your xRC Sim game instance to output data files to distinct folders of your choice.

3. Create and rearrange GDI+ text sources in your OBS scenes to display live game information. The text sources must match the exact naming conventions of the script.

    * Text Source Naming Conventions for Sim Data 1:
        * "Match Timer", "Red Score", "Blue Score", "Red Penalty Points", "Blue Penalty Points", "Red Auto Points", "Blue Auto Points", "Red Teleop Points", "Blue Teleop Points", "Red Endgame Points", "Blue Endgame Points", "Red Game Pieces", "Blue Game Pieces", "Red Charge Station Points", "Blue Charge Station Points", "Red-OPR", "Blue-OPR", "Red RP", "Blue RP", "Red Result", "Blue Result", "Red Links", "Blue Links", "OPR"
            * Note that some of these sources are game specific and may not apply to all games!
    * For Sim Data 2-4, simply append a space and the number to the name of the text source.
         * For example for Sim Data 2, a text source should be named "Match Timer 2".

## License and Contributing

This project is licensed under the MIT License. This roughly means that any usage of this project is authorized, under the condition that you provide attribution. See [LICENSE](LICENSE) for more information.

Contributions are welcomed and encouraged! Please make a fork of this repository and submit a pull request with your changes. If you have any questions, feel free to open an issue.
