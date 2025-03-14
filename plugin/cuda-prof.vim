lua require('cuda-prof')

command! -nargs=* CudaCompile lua require('cuda-prof.profiler').nvcc.nvccCompile(<q-args>)
command! -nargs=* CudaProfile lua require('cuda-prof.profiler').nsys.nsysTracing(<q-args>)
command! -nargs=* CudaCompute lua require('cuda-prof.profiler').ncu.ncuTracing(<q-args>)
command! -nargs=* CudaVisual lua require('cuda-prof.profiler').nvvp.nvvpTracing(<q-args>)

command! -nargs=0 CudaProfileDir lua require('cuda-prof').profile_with_dir()
function! s:profile_with_dir() abort
    let dir = 'profiles/build_' . strftime('%Y%m%d_%H%M%S')
    call mkdir(dir, 'p')
    execute 'CudaProfile ./%:r -o ' . dir . '/profile'
endfunction

nnoremap <leader>cc :CudaCompile -o %:r % -arch=sm_89<CR>
nnoremap <leader>cp :CudaProfileDir<CR>
nnoremap <leader>cu :CudaCompute ./%:r<CR>
nnoremap <leader>cv :CudaVisual ./%:r<CR>

" Optional: Git hash in profile dir
command! -nargs=0 CudaProfileGit lua require('cuda-prof').profile_with_git()
function! s:profile_with_git() abort
    let git_hash = system('git rev-parse --short HEAD')[0:-2]
    let dir = 'profiles/build_' . strftime('%Y%m%d_%H%M%S') . '_' . git_hash
    call mkdir(dir, 'p')
    execute 'CudaProfile ./%:r -o ' . dir . '/profile'
    call writefile(['Git: ' . git_hash], dir . '/meta.txt')
endfunction
nnoremap <leader>cg :CudaProfileGit<CR>

echom "cuda-tools.nvim loaded"
