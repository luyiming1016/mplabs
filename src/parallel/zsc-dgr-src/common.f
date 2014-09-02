!-------------------------------------------------------------------------------
! File     : Common
! Revision : 1.1 (2008-11-10)
! Author   : David S. Whyte [david(at)ihpc.a-star.edu.sg]
!-------------------------------------------------------------------------------
!> @file
!! Modules that contain common variables

!-------------------------------------------------------------------------------
! Copyright 2008 Carlos Rosales Fernandez, David S. Whyte and IHPC (A*STAR).
!
! This file is part of MP-LABS.
!
! MP-LABS is free software: you can redistribute it and/or modify it under the
! terms of the GNU GPL version 3 or (at your option) any later version.
!
! MP-LABS is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
! A PARTICULAR PURPOSE. See the GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along with
! MP-LABS, in the file COPYING.txt. If not, see <http://www.gnu.org/licenses/>.
!-------------------------------------------------------------------------------

!> @brief Definition of single and double data types
 MODULE NTypes
 IMPLICIT NONE
 SAVE

 INTEGER, PARAMETER :: SGL = KIND(1.0)
 INTEGER, PARAMETER :: DBL = KIND(1.D0)

 END MODULE NTypes

!> @brief Parameters related to the geometry and the time intervals
 MODULE Domain
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! Maximum time of steps and data dump times
 INTEGER :: MaxStep, RelaxStep, iStep, tCall, tDump, tStat

! Domain size
 INTEGER :: xmin, xmax, ymin, ymax, xmin_f, xmax_f, ymin_f, ymax_f
 INTEGER :: xl, xu, yl, yu, xl_f, xu_f, yl_f, yu_f
 INTEGER :: xlg, xug, ylg, yug, xlg_f, xug_f, ylg_f, yug_f
 INTEGER :: xsize, xsize6, xsize_f
 INTEGER :: ysize, ysize6, ysize_f
 INTEGER :: now, nxt, NX, NY, NX_f, NY_f

! ndim = spatial dimension
 INTEGER, PARAMETER :: ndim = 2

! Neighbour arrays
 INTEGER, ALLOCATABLE, DIMENSION(:,:,:) :: ni, ni_f

! Effective volume and radius
 REAL(KIND = DBL) :: invInitVol

! Define constants used in the code (inv6 = 1/6, inv12 = 1/12, invPi = 1/pi)
 REAL(KIND = DBL), PARAMETER :: inv6  = 0.16666666666666666667D0
 REAL(KIND = DBL), PARAMETER :: inv12 = 0.08333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: invPi = 0.31830988618379067154D0

 END MODULE Domain

!> @brief Parameters related to hydrodynamics quantities
 MODULE FluidParams
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

 INTEGER :: nBubbles
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:) :: bubbles
 REAL(KIND = DBL), DIMENSION(1:11) :: Convergence
 REAL(KIND = DBL) :: D, sigma, IntWidth
 REAL(KIND = DBL) :: alpha, alpha4, kappa, kappaG
 REAL(KIND = DBL) :: rhoL, rhoH, tauRho, invTauRho, invTauRho2
 REAL(KIND = DBL) :: tauPhi, invTauPhi
 REAL(KIND = DBL) :: phiStar, phiStar2, phiStar4
 REAL(KIND = DBL) :: Gamma, eps, pConv
 REAL(KIND = DBL) :: eta, eta2, invEta2

! Velocity and pressure arrays
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:)   :: p, p_f
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:,:) :: u, u_f

! Order parameter and differential arrays
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:) :: phi_f, lapPhi_f
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:) :: gradPhiX_f, gradPhiY_f

 END MODULE FluidParams

!> @brief Parameters related to the LBM discretization
 MODULE LBMParams
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! fdim = order parameter distribution dimension - 1 (D2Q5)
! gdim = momentum distribution dimension - 1 (D2Q9)
 INTEGER, PARAMETER :: fdim = 4
 INTEGER, PARAMETER :: gdim = 8

! Distribution functions
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:,:)   :: f, fcol
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:,:,:,:) :: g

! D2Q5/D2Q9 Lattice speed of sound (Cs = 1/DSQRT(3), Cs_sq = 1/3, invCs_sq = 3)
 REAL(KIND = DBL), PARAMETER :: Cs       = 0.57735026918962576451D0
 REAL(KIND = DBL), PARAMETER :: Cs_sq    = 0.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: invCs_sq = 3.00000000000000000000D0

! Distributions weights (D2Q9: Eg0 = 4/9, Eg1 = 1/9, Eg2 = 1/36)
 REAL(KIND = DBL), PARAMETER :: Eg0 = 0.44444444444444444444D0
 REAL(KIND = DBL), PARAMETER :: Eg1 = 0.11111111111111111111D0
 REAL(KIND = DBL), PARAMETER :: Eg2 = 0.02777777777777777778D0

! Modified distribution weight (to avoid operations: EgiC = Egi*invCs_sq)
 REAL(KIND = DBL), PARAMETER :: Eg0C = 1.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: Eg1C = 0.33333333333333333333D0
 REAL(KIND = DBL), PARAMETER :: Eg2C = 0.08333333333333333333D0
 REAL(KIND = DBL) :: Eg0T, Eg1T, Eg2T

 END MODULE LBMParams

!> @brief MPI related parameters and information exchange buffer arrays
!> @details
!! @param nprocs  : total number of processors
!! @param proc    : processor ID
!! @param vproc   : processor ID in virtual grid
!! @param mpi_dim : virtual grid partition scheme (1->stripes, 2->boxes, 3->cubes)
 MODULE MPIParams
 USE NTypes, ONLY : DBL
 IMPLICIT NONE
 SAVE

! Communication parameters
 INTEGER :: MPI_COMM_VGRID
 INTEGER :: nprocs, proc, vproc
 INTEGER :: mpi_xdim, mpi_ydim
 INTEGER :: east, west, north, south, ne, nw, se, sw
 INTEGER, PARAMETER :: master  = 0
 INTEGER, PARAMETER :: mpi_dim = 2

! Constants used as tags
 INTEGER, PARAMETER :: TAG1 = 1, TAG2 = 2, TAG3 = 3, TAG4 = 4

! Information exchange buffers (x direction)
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: f_west_snd, f_west_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: f_east_snd, f_east_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: phi_west_snd, phi_west_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: phi_east_snd, phi_east_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: hydro_west_snd, hydro_west_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: hydro_east_snd, hydro_east_rcv

! Information exchange buffers (y direction)
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: f_south_snd, f_south_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: f_north_snd, f_north_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: phi_north_snd, phi_north_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: phi_south_snd, phi_south_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: hydro_south_snd, hydro_south_rcv
 REAL(KIND = DBL), ALLOCATABLE, DIMENSION(:) :: hydro_north_snd, hydro_north_rcv

! Information exchange buffers (diagonals)
 REAL(KIND = DBL) :: phi_ne_snd, phi_ne_rcv
 REAL(KIND = DBL) :: phi_se_snd, phi_se_rcv
 REAL(KIND = DBL) :: phi_nw_snd, phi_nw_rcv
 REAL(KIND = DBL) :: phi_sw_snd, phi_sw_rcv
 REAL(KIND = DBL), DIMENSION(1:4) :: hydro_ne_snd, hydro_ne_rcv
 REAL(KIND = DBL), DIMENSION(1:4) :: hydro_se_snd, hydro_se_rcv
 REAL(KIND = DBL), DIMENSION(1:4) :: hydro_nw_snd, hydro_nw_rcv
 REAL(KIND = DBL), DIMENSION(1:4) :: hydro_sw_snd, hydro_sw_rcv

 END MODULE MPIParams
