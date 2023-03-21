# fifo.sh

An implementation of FIFO without using `mkfifo`

## Overview

fifo.sh is an implementation of FIFO without using `mkfifo` which sometimes can be annoying to use.

To use fifo.sh, you need at least Bash 4.3+ and coreutils.

## Installation

Via bpkg:
```bash
bpkg install UrNightmaree/fifo.sh
```
Via manual:
```bash
cp fifo.sh/fifo.sh path/to/my-project
```

## Index

* [fifo_new](#fifo_new)
* [fifo_length](#fifo_length)
* [fifo_peek](#fifo_peek)
* [fifo_push](#fifo_push)
* [fifo_pop](#fifo_pop)
* [fifo_insert](#fifo_insert)
* [fifo_remove](#fifo_remove)
* [fifo_setempty](#fifo_setempty)

### fifo_new

Creates a FIFO object (an associative array)

#### Example

```bash
fifo_new myfifo data1 data2 data3
```

#### Arguments

* **$1** (string): FIFO object variable name
* **...** (any): Any data to be passed into FIFO

### fifo_length

Get length of a FIFO

#### Example

```bash
fifo_length myfifo #=> 3
```

#### Arguments

* **$1** (FIFO-object): A FIFO object

#### Output on stdout

* Length of the FIFO

### fifo_peek

Get data from FIFO without removing it from the FIFO

#### Example

```bash
fifo_peek myfifo   #=> data1
fifo_peek myfifo 3 #=> data3
```

#### Arguments

* **$1** (FIFO-object): A FIFO object
* **$2** (integer?): Index of FIFO data, defaults to 1

#### Output on stdout

* Value of data

### fifo_push

Push value into FIFO

#### Example

```bash
fifo_push myfifo data4
```

#### Arguments

* **$1** (FIFO-object): A FIFO object
* **$2** (any): Any value to be pushed

### fifo_pop

Pop a data inside FIFO

#### Example

```bash
fifo_pop myfifo #=> data4
```

#### Arguments

* **$1** (FIFO-object): A FIFO object

#### Output on stdout

* Value of the data

### fifo_insert

Insert value into FIFO with custom index

#### Example

```bash
fifo_insert myfifo 10 data-custom
```

#### Arguments

* **$1** (FIFO-object): A FIFO object
* **$2** (integer): Index to be inserted
* **$3** (any): Any value to be inserted at index

### fifo_remove

Remove data from FIFO at index

#### Example

```bash
fifo_remove myfifo 10 #=> data-custom
```

#### Arguments

* **$1** (FIFO-object): A FIFO object
* **$2** (integer): Index to be remkved

#### Output on stdout

* The value of the removed data

### fifo_setempty

Set empty function

#### Arguments

* **$1** (FIFO-object): A FIFO object
* **$2** (function): Function to be executed when empty

