(function (storyContent) {

    // Create ink story from the content using inkjs
    const story = new inkjs.Story(storyContent);

    let globalTagTheme;

    // Global tags - those at the top of the ink file
    // We support:
    //  # theme: dark
    //  # author: Your Name
    if (story.globalTags) {
        for (let i = 0; i < story.globalTags.length; i++) {
            const splitTag = splitPropertyTag(story.globalTags[i]);

            // theme: dark
            if (splitTag && splitTag.property == "theme") {
                globalTagTheme = splitTag.val;
            }

            // author: Your Name
            else if (splitTag && splitTag.property == "author") {
                const byline = document.querySelector('.byline');
                byline.innerHTML = "from " + splitTag.val;
            }
        }
    }

    // page features setup
    setupTheme(globalTagTheme);
    setupButtons();

    setupKeypad();

    // Kick off the start of the story!
    continueStory();

    // Main story processing function. Each time this is called it generates
    // all the next content up as far as the next set of choices.
    function continueStory() {

        // Generate story text - loop through available content
        while (story.canContinue) {

            // Get ink to generate the next paragraph
            const paragraphText = story.Continue();

            // Any special tags included with this line
            for (const tag of story.currentTags) {
                if (tag === "MEMORY") {
                    document.querySelector("#calculator .calculator__output__memory").textContent = "M";
                }

                else if (tag === "NOMEMORY") {
                    document.querySelector("#calculator .calculator__output__memory").textContent = "";
                }
            }

            if (paragraphText.startsWith(">>> LOG:")) {
                console.log(paragraphText);
            } else {
                document.querySelector("#calculator .calculator__output__number").textContent = paragraphText;
            }
        }
    }


    // -----------------------------------
    // Various Helper functions
    // -----------------------------------

    // Helper for parsing out tags of the form:
    //  # PROPERTY: value
    // e.g. IMAGE: source path
    function splitPropertyTag(tag) {
        const propertySplitIdx = tag.indexOf(":");
        if (propertySplitIdx) {
            const property = tag.substr(0, propertySplitIdx).trim();
            const val = tag.substr(propertySplitIdx + 1).trim();
            return {
                property: property,
                val: val
            };
        }

        return null;
    }

    // Detects which theme (light or dark) to use
    function setupTheme(globalTagTheme) {

        // Check whether the OS/browser is configured for dark mode
        const browserDark = window.matchMedia("(prefers-color-scheme: dark)").matches;

        if ((globalTagTheme === "dark") || (globalTagTheme == undefined && browserDark))
            document.body.classList.add("dark");
    }

    // Used to hook up the functionality for global functionality buttons
    function setupButtons() {
        document.getElementById("theme-switch")?.addEventListener("click", function (event) {
            document.body.classList.add("switched");
            document.body.classList.toggle("dark");
        });

        document.getElementById("flip")?.addEventListener("click", function (event) {
            document.getElementById("calculator")?.classList.toggle("upside-down");
        });
    }

    function setupKeypad() {
        for (const button of document.querySelectorAll("#calculator button")) {
            button.addEventListener("click", function (event) {
                const op = button.dataset.op;
                const choice = story.currentChoices.find(choice => choice.text === `>>> KEYPAD: ${op}`);
                if (choice) {
                    story.ChooseChoiceIndex(choice.index);
                    continueStory();
                }
            });
        }

        window.addEventListener("keydown", function (event) {
            const button = findButton(event.key, event.ctrlKey);
            if (button) {
                event.preventDefault();
                button.click();
            }
        });
    }

    function findButton(key, ctrlKey) {
        if (key === "Enter") {
            return document.querySelector(`#calculator button[data-op="="]`);
        } else if (key === "Del" || key === "Delete" || key === "Esc" || key === "Escape") {
            return document.querySelector(`#calculator button[data-op="AC"]`);
        } else if (key === "q" && ctrlKey) {
            return document.querySelector(`#calculator button[data-op="M-"]`);
        } else if (key === "p" && ctrlKey) {
            return document.querySelector(`#calculator button[data-op="M+"]`);
        } else if (key === "m" && ctrlKey) {
            return document.querySelector(`#calculator button[data-op="MS"]`);
        } else if (key === "r" && ctrlKey) {
            return document.querySelector(`#calculator button[data-op="MR"]`);
        } else if (key === "l" && ctrlKey) {
            return document.querySelector(`#calculator button[data-op="MC"]`);
        } else if (key === "r") {
            return document.querySelector(`#calculator button[data-op="1/x"]`);
        } else if (key === "@") {
            return document.querySelector(`#calculator button[data-op="sqrt"]`);
        } else if (key === "F9") {
            return document.querySelector(`#calculator button[data-op="+-"]`);
        } else {
            return document.querySelector(`#calculator button[data-op="${key}"]`);
        }
    }

})(storyContent);
