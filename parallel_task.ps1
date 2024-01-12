function Run-Tasks
{
    Param
    (
        $taskArr,
        $parallelcount=1
    )

    #测试计时开始
    $startTime = (Get-Date)
    
    #移除本次会话中已有的所有后台任务
    Remove-Job *
    
    # 使用变量 $taskCount 保存还没有执行完成的任务数
    $taskCount = $taskArr.Length
    
    #判断设定的并行任务数是否超过当前任务队列中的任务数
    if($parallelCount -gt $taskArr.Length)
    {
        $parallelCount = $taskArr.Length
    }
    #启动初始任务
    foreach($i in 1..$parallelCount)
    {
        Start-Job $taskArr[$i - 1] -Name "task$i"
    }

    #初始任务完成后开始的任务
    $nextIndex = $parallelCount
    
    #当任务队列中还有任务时不断轮询已建立的任务，当一个后台任务结束时删除这个任务，
    #然后从任务队列中取出下一个任务进行执行，然后等待所有任务执行完成。
    while(($nextIndex -lt $taskArr.Length) -or ($taskCount -gt 0))
    {
        foreach($job in Get-Job)
        {
            $state = [string]$job.State
            if($state -eq "Completed")
            {   
                Write-Host($job.Name + " 已经完成，结果如下：")
                Receive-Job $job
                Remove-Job $job
                $taskCount--
                if($nextIndex -lt $taskArr.Length)
                {   
                    $taskNumber = $nextIndex + 1
                    Start-Job $taskArr[$nextIndex] -Name "task$taskNumber"
                    $nextIndex++
                }
            }
        }
        sleep 1
    }
    
    "所有任务已完成"
    #得出任务运行的时间
    (New-TimeSpan $startTime).totalseconds
}