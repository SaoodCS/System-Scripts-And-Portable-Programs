# LINKING custom.omp.json TO TERMINAL

1. Install OhMyPosh
2. Copy the path of the custom.omp.json file in this folder
3. Open the Terminal app -> Open a PowerShell tab in the app
4. Run in PowerShell: `notepad $PROFILE`
5. Add/Update the following line with the path of custom.omp.json
   - `oh-my-posh init pwsh --config "C:\path\to\custom.omp.json" | Invoke-Expression`
