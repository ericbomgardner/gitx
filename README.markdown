# What is GitX?

GitX is a graphical client for the `git` version control system.

This means that it has a native interface and tries to integrate with the
operating system as good as possible. Examples of this are drag and drop
support and QuickLook support.

# Features

  * Simple line-by-line staging
  * History browsing of your repository
  * See a nicely formatted diff of any revision
  * Search based on author or revision subject
  * Look at the complete tree of any revision
    * Preview any file in the tree in a text view or with QuickLook
    * Drag and drop files out of the tree view to copy them to your system
  * Good performance on large (200+ MB) repositories

# Development

To get GitX to compile locally you need to:

  1. Clone the repository locally: `git clone https://github.com/ericbomgardner/gitx.git`
  2. After cloning it `cd gitx` and then recursively initialize all submodules: `git submodule update --init --recursive`
  3. Then prepare objective-git by running its bootstrap script: `cd objective-git && ./script/bootstrap`
  4. Then compile objective-git `cd objective-git && ./script/update_libgit2`

After that you should be able to open the Xcode project and build successfully.

# License

GitX is licensed under the GPL version 2. For more information, see the attached COPYING file.

# Usage

GitX itself is fairly simple. Most of its power is in the 'gitx' binary, which
you should install through the menu. the 'gitx' binary supports most of git
rev-list's arguments. For example, you can run `gitx --all` to display all
branches in the repository, or `gitx -- Documentation` to only show commits
relating to the 'Documentation' subdirectory. With `gitx -Shaha`, gitx will
only show commits that contain the word 'haha'. Similarly, with `gitx
v0.2.1..`, you will get a list of all commits since version 0.2.1.

# Helping out

Any help on GitX is welcome. GitX is programmed in Objective-C, but even if
you are not a programmer you can do useful things. A short selection:

  * Give feedback
