#pragma once

#include <string>
#include <curses.h>
#include "TextInput.h"
#include "ToggleInput.h"
#include "InputBox.h"

/*******************************************************************************

Search dialog

*******************************************************************************/
class SearchBox: public InputBox {

  private:

    TextInput _entryitem;
    ToggleInput _caseitem, _wholeitem;

    /* Drawing */

    void redrawFrame() const;

  public:

    /* Constructors */

    SearchBox();
    SearchBox(WINDOW *win, const std::string & msg);

    /* Get attributes */

    std::string searchString() const;
    bool caseSensitive() const;
    bool wholeWord() const;
};
