We jail our users by calling unshare(CLONE_NEWNS) (see man 2 unshare) from a
pam module, followed by a custom script which creates the jail by bind
mounting things and then pam chroots the session.
This sequence (optional, optional, required) is failsafe:

* If pam_unshare fails, the pam_script will do a check that the mount
  namespace of the session is different from /proc/1/ns/mnt and fail. 
* If pam_script fails, the mounts will not exist and pam_chroot will fail
  because it won't find the user's home directory, among other things.

This is failsafe for the ubuntu and root users since pam_script does nothing
for users not in the databox group.