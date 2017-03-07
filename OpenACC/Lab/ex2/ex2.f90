PROGRAM MAIN
    USE ISO_FORTRAN_ENV, ONLY : output_unit,real64
    IMPLICIT NONE
    REAL*8, ALLOCATABLE :: var(:,:,:), tmp(:,:,:)
    INTEGER ::  nx,ny,nz,nt
    REAL( real64) :: ct_one, ct_two, ct_three
    REAL( real64) :: elapsed_time, loop_time, init_time
    INTEGER :: i,j,k,n
    CALL cpu_time( time= ct_one)
    !////////////////////////////////////////////////////
    ! Set some default values for the problem parameters.
    nx = 256   ! x-dimension of our 3-D array
    ny = 256   ! y-dimension of our 3-D array
    nz = 256   ! z-dimension of our 3-D array
    nt = 100   ! number of time steps to integrate over

    !////////////////////////////////////////////////////
    ! Check to see if the user has specified anything 
    ! different at the command line.
    CALL grab_args(nx,ny,nz,nt)

    WRITE(output_unit,'(a)') ' ///////////////////////////'
    WRITE(output_unit,'(a)') '  3-D Diffusion Equation   '
    WRITE(output_unit,'(a)') '  --Problem Parameters-- '
    WRITE(output_unit,'(a,i0)')'   nx =', nx
    WRITE(output_unit,'(a,i0)')'   ny =', ny
    WRITE(output_unit,'(a,i0)')'   nz =', nz
    WRITE(output_unit,'(a,i0)')'   nt =', nt
    WRITE(output_unit,'(a)') ' ///////////////////////////'
    WRITE(output_unit,'(a)') ' '
    !/////////////////////////////////////////////////////
    ! Initialize var and the work array
    ALLOCATE(var(1:nx,1:ny,1:nz))
    ALLOCATE(tmp(1:nx,1:ny,1:nz))
    
    var(:,:,:) = 0.0d0
    tmp(:,:,:)   = 0.0d0

    !/////////////////////////////////////////////////////
    ! Evolve the system

    CALL cpu_time( time= ct_two)
    DO n = 1, nt,2
        Write(output_unit,'(a,i5)')' Timestep: ',n
        CALL Laplacian(var,tmp)
        Write(output_unit,'(a,i5)')' Timestep: ',n+1
        CALL Laplacian(tmp,var)
    ENDDO

    CALL cpu_time( time= ct_three)
    elapsed_time = ct_three-ct_one
    init_time = ct_two-ct_one
    loop_time = ct_three-ct_two
    WRITE(output_unit,'(a)')' Complete!'
    WRITE(output_unit,'( a, ES14.4, a)')'         Elapsed time: ', elapsed_time, ' seconds.'
    WRITE(output_unit, fmt= '( a, ES14.4, a)') '  Initialization time: ', init_time, ' seconds.'
    WRITE(output_unit, fmt= '( a, ES14.4, a)') '            Loop time: ', loop_time, ' seconds.'

    
CONTAINS

    SUBROUTINE Laplacian(arrin, arrout)
        IMPLICIT NONE
        REAL*8, INTENT(In) :: arrin(:,:,:)
        REAL*8, INTENT(Out) :: arrout(:,:,:)
        INTEGER :: dims(3), ni, nj, nk
        dims = shape(arrin)
        nk = dims(3)
        nj = dims(2)
        ni = dims(1)
        DO k = 2, nk-1
            DO j = 2, nj-1
                DO i = 2, ni-1
                    arrout(i,j,k) = arrin(i,j,k) + &
                            arrin(i-1,j,k) + arrin(i+1,j,k) + &
                            arrin(i,j-1,k) + arrin(i,j+1,k)  
                ENDDO
            ENDDO
        ENDDO
    END SUBROUTINE Laplacian

    SUBROUTINE grab_args(numx, numy, numz, numiter)
            IMPLICIT NONE

            INTEGER, INTENT(OUT)   :: numx
            INTEGER, INTENT(OUT)   :: numy
            INTEGER, INTENT(OUT)   :: numz
            INTEGER, INTENT(OUT)   :: numiter


            INTEGER :: n                    ! Number of command-line arguments
            INTEGER :: i                    
            CHARACTER(len=1024) :: argname  ! Argument key
            CHARACTER(len=1024) :: val      ! Argument value



            n = command_argument_count()
            DO i=1,n,2
                    CALL get_command_argument(i, argname)
                    CALL get_command_argument(i+1, val)
                    SELECT CASE(argname)
                            CASE('-nx')
                                    read(val, '(I8)') numx
                            CASE('-ny')
                                    read(val, '(I8)') numy
                            CASE('-nz')
                                    read(val, '(I8)') numz
                            CASE('-nt')
                                    read(val, '(I8)') numiter
                            CASE DEFAULT
                                    WRITE(output_unit,'(a)') ' '
                                    WRITE(output_unit,'(a)') &
                                    ' Unrecognized option: '// trim(argname)
                    END SELECT
            ENDDO
            IF (MOD(nt,2) .eq. 1) THEN
                WRITE(output_unit,'(a)')' '
                WRITE(output_unit,'(a)')' //////////////////////////////////////////////////'
                WRITE(output_unit,'(a)')'  NOTE:  Parameter nt must be even for this example.'
                WRITE(output_unit,'(a,i0,a,i0,a)')'   Changing nt from ',nt,' to ', nt+1,'.'
                WRITE(output_unit,'(a)')' //////////////////////////////////////////////////'
                WRITE(output_unit,'(a)')' '
                nt = nt+1
            ENDIF


    END SUBROUTINE grab_args

END PROGRAM MAIN