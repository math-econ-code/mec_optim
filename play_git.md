# A short introduction to version control using Git

## Installation

If you followed the steps in the first lecture, then you should already have Git installed. If not here they are again:

- **Mac users:** open terminal and run ```git --version```. If you don't have git installed, you will be prompted to do so.
- **Windows users:** go to the [Git for Windows](https://gitforwindows.org/) download page and install. I recommend also installing [notepad++](https://notepad-plus-plus.org/) for a text editor, unless you already use SublimeText or vim.

## What is Git

Git is really good version control. Anyone who has done a large project or even editing on a text document has done something like

* `foobar`

* `foobar_final`

* `foobar_final2`

* `foorbar_actuallyfinal`

If you were smart, you may have added dates or explained briefly what you were trying to do with a particular version of that file. Git is the way to do this properly, and in such a way that you can easily collaborate with others and all work on the project at the same time.

## Today

This will be an amalgamation of several different Git tutorials. These include

* https://git-scm.com/docs/gittutorial

* https://opensource.com/education/16/1/git-education-classroom

* https://www.atlassian.com/git/tutorials

We will try to cover enough of the basis that you can start using Git in your day to day work. This will by no means be exhaustive, so if you are still interested in learning, I encourage you to do so.

Before we start anything let's introduce ourselves to Git. Open up cmd / terminal and type

```bash
git config --global user.name "Your Name Comes Here"
git config --global user.email you@yourdomain.example.com
```

Let's cook up a new directory to use as our Git repository.

```
mkdir gitdemo
cd gitdemo
git init
```

So we now have an empty Git repository You'll see Initialized empty Git repository in `gitdemo/.git/`. What's that `.git`? If you list all files in your directory (`ls -a`), you'll see a new hidden `.git/` directory. That's where Git stores the information about this new repository. Time to add some files.

```
touch new.txt
echo "Hello, World!" > new.txt 
```

Let's check out what is happening in our repository, now that we have included a new file

```
git status
```

* We can have multiple versions of this folder, and you're looking at one called *master*.
* No commits (saves) have been made yet.
* I see some files in this folder you haven't told me to care about yet. Here they are...

Before we can add `test.txt` we need to 'stage' it (The staging area is key feature of Git and can be a little strange at first. It would seem sensible to just commit changes instead of having to first stage them, then committing them. However staging allows very fine tuned control of our snapshots of our project before committing them. This will make version control and reverting changes much easier, but it of course relies on you having good habits.)

```
git add new.txt
git status
```

Then we can commit it

```
git commit -m "Initial commit"
```

Where `-m` is the flag for a commit message. 

Now let's change up our `test.txt` file. 

```
echo "Foobar!" >> new.txt 
```

We can examine the difference between our old and new versions of `new.txt`

```
git diff new.txt
```

And if we like the changes, we can stage them (`git add -u` will stage all currently tracked files), then commit the changes

```
git add -u
git commit -m "Updated new.txt"
```

We can examine our project history

```
git log --oneline
```

## Managing branches

When we plan on making large changes to our code, we should form a new branch for our code. This way we can do development on a particular feature, but still have a working version of our code, should we need it. Let's create a new branch called `experimental`

```
git branch experimental
git branch
```

And we will get a list of all existing branches:

```
  experimental
* master
```

We are currently checked out on `master`. To get onto the `experimental` branch

```
git checkout experimental
```

Let's edit our `new.txt` file and also create some new files 

```
echo "Fizz" > new.txt
echo a > 1.txt
echo b > 2.txt
echo c > 3.txt
```

Add them to the staging area

```
git add --all
```

And commit

```L
git commit -m "Doing some crazy stuff here"
```

Let's go back to our `master` branch

```
git checkout master
```

And not only do our new files disappear, but the changes to `new.txt` disappear as well. At this point, if we wanted to incorporate the `experimental` branch into the `master` branch, we could type

```
git merge experimental
```

And we would get a seamless merge. But let's make things a little bit harder and suppose we make a change on our master branch

```
echo "Buzz" > new.txt
git add -u
git commit -m "Buzz!"
```

Now `master` and `experimental` have diverged. To merge the changes in experimental into master

```
git merge experimental
```

You will see here that we get a conflict warning. The file `new.txt` differs in the master and experimental branches, and hence merging them delivers us a conflict. Before we can finish our merge we need to decide exactly how this merge will work. If we open up this text file

```
<<<<<<< HEAD
"Buzz" 
=======
"Fizz" 
>>>>>>> experimental
```

Everything between `<<<<<<< HEAD` and `=======` is in the master branch and between `=======` and `>>>>>>> experimental` in the experimental branch. Let's resolve this saving

```
"Buzz"
```

Everything between `<<<<<<< HEAD` and `=======` is in the master branch and between `=======` and `>>>>>>> experimental` in the experimental branch. Let's resolve this saving

```
"Buzz"
```

We can now stage and commit these stages to complete the merge.

```
git add --all
git commit -am "Resolved merge conflicts"
```

 If we no longer need the experimental branch, we can remove it.

```
git branch -d experimental
```

## Undo changes

### Uncommitted changes

First let's suppose you have made some changes but you want to discard these changes before you commit them (assuming they haven't been staged).

```
echo "I am going to discard you" > new.txt
git status
```

There are 3 options here

1. Discard all local changes, but save them for possible re-use [later](https://docs.gitlab.com/ee/topics/git/numerous_undo_possibilities_in_git/#quickly-save-local-changes)	

  ```
  git stash
  ```

  If going this route, you can switch to a different branch and do some work and come back to your stashed files using

  ```
  git stash list
  git stash apply
  ```

2. Discarding local changes (permanently) to a file

  ```
    git checkout -- <file>
  ```

3. Discard all local changes to all files permanently

  ```
    git reset --hard
  ```

If the files have been staged, the 3 commands above work. But so does

```
git reset HEAD <file>
```

Which will unstage the file to the current commit.

### Committed changes

If we want to undo committed changes, there are several different ways to do this. If we need to checkout a commit in a branch then we can use checkout. 

```
git checkout -b new
echo something > new.txt
git commit -am "Something"
echo something1 > new.txt
git commit -am "Something else"
git log --oneline
```

We can checkout the commit for `Something`

```
git checkout <Something-id>
```

And if we want to, we can create a new branch

```
git checkout -b Fixes
```

And then merge this with the master branch, at some point in the future. Instead we could use the `reset` command

```
git log --oneline
git reset <Resolved-merge-conflicts-id>
```

Which completely deletes the past history. This leads to much cleaner history, but we do lose some history (which we may need for later).

There is a good lesson to learn about using Git. If we do development on the `master` branch, then we can't use `checkout` and creating a new branch. Therefore we should only use `master` for stable code. Any development should be done on a `development` branch, and then when adding specific features using branches off the development branch. There exist some standardized workflows for Git branches (e.g. [git-flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)). These are likely overkill for a lot of the projects that we typically work on. But if you are part of a larger project they are worth considering.



## Remote Repositories

Cloning a repository is something that we have done already. For example to clone	

```
git clone https://github.com/jmcgnesbit/github_test.git
```

If you create a github account, <your GH username> and create a repository <your repo name>, you can push the repo that you developed today into that Github repo.

```
git remote add origin https://github.com/<your GH username>/<your repo name>.git
git push -u origin master
```