# Basic submission of acts jobs

Collection of scripts to submit simple acts jobs to the condor batch. 
The basic submission script is `base_acts.sub`. This script will setup and call `acts_test.sh` which contains the job specifications. 
Currently, my own setup paths and location of running scripts are hardcoded in the submission scripts, so they won't work for you directly.

This submission will work for the following acts `repository::branch`: `https://github.com/pbutti/acts ::  tracking`

## How to run

0) You need to have acts compiled on your `/afs`. 

Modify `acts_test.sh`

1) Change the `source` lines to point to the setup scripts in your acts installation. 
2) Change the line after `#### THE JOB ####` to point to the right path to your acts installation. 
3) Change the line where the copy to eos is specified, putting the eos folder where you want to collect the output. The folder need to exist.

Modify `base_acts.sub`

4) Change the "executable" to point to your path. 
In arguments, 1000 stands for the number of events. You can change it if you want to run a different number of events. 
In the line `queue` you can change the number of submitted jobs. I chose 100. So the submission will run about 100k events (leading to about 400k jets)

### Simple submission for running the jet chain

To submit the jobs in condor just 
```
condor_submit base_acts.sub
```
You can monitor the job status by `condor_q`
When your jobs are going to finish, you'll have the output in the eos folder specified in `base_acts.sub`

