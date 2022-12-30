# getTermSize.sh
Bash utility scripts to obtain width and/or height of the current terminal window.

## Overview

All three scripts will return the width, height, or width and height of the current terminal. Furthermore, they are intended to be portable, but that cannot be guranteed.
The three (3) sepeate scripts are `getTermWidth`, `getTermHeight`, and `getTermSize`.


## `getTermWidth`

### Usage
Usage is quite simple and takes no parameters or arguments. 

The returned value will be an integer (the number of characters equal to the width of the terminal window)

### Details

When the script is called, it actively returns (to `STDOUT`) the width of the terminal screen as an integer.

However, it may also be `source`'d, inwhich case, it will get, set, and `export` the screen width as the <mark>variable **`$TERMINAL_WIDTH`**</mark>

### Example

#### 1). Active Use
```bash
TERMINAL_WIDTH="$(getTermWidth)"
### printf "$TERMINAL_WIDTH"  ### => 156
```

#### 2). Sourcing (Passive) Use
```bash
source getTermWidth
### printf "$TERMINAL_WIDTH"  ### => 156
```


## `getTermHeight`

### Usage
Usage is, again, quite simple and takes no parameters or arguments. 

The returned value will be an integer (the number of characters equal to the *height* of the terminal window)

### Details

When the script is called, it actively returns (to `STDOUT`) the height of the terminal screen as an integer.

However, it may also be `source`'d, inwhich case, it will get, set, and `export` the screen width as the <mark>variable **`$TERMINAL_HEIGHT`**</mark>

### Example

#### 1). Active Use
```bash
TERMINAL_HEIGHT="$(getTermHeight)"
### printf "$TERMINAL_Height"  ### => 24
```

#### 2). Sourcing (Passive) Use
```bash
source getTermHeight
### printf "$TERMINAL_HEIGHT"  ### => 24
```

## `getTermSize`

### Usage
This script is a little different.

The returned value(s) will be one/a set of integer(s) (the number of characters equal to the width,height or both width and height of the terminal window)

### Details

When the script is called, it actively returns (to `STDOUT`) the width of the terminal screen as an integer.

However, it may also be `source`'d, inwhich case, it will get, set, and `export` the screen width as the <mark>variable **`$TERMINAL_WIDTH`**</mark>

### Example

#### 1). Active Use
```bash
TERMINAL_WIDTH="$(getTermSize -w)"
TERMINAL_HEIGHT="$(getTermSize -h)"

### printf "$TERMINAL_WIDTH"   ### => 156
### printf "$TERMINAL_HEIGHT"  ### => 24
```

#### 2). Sourcing (Passive) Use
```bash
source getTermSize

### printf "$TERMINAL_WIDTH"   ### => 156
### printf "$TERMINAL_HEIGHT"  ### => 24
```