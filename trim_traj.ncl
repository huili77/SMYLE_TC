; trim basin for the original tracked data


;========================================================
; This file reads in a traj file produced by the TC tracker
; and produces a lat-lon plot of trajectories color-coded by intensity
;========================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/glade/u/home/zarzycki/ncl/functions/surfaceWindCorrFactor.ncl"
load "/glade/u/home/zarzycki/ncl/functions/getTrajectoriesGeneric.ncl"
load "/glade/u/home/zarzycki/ncl/functions/mask_tc.ncl"

;========================================================
begin


maskspacing=1.0
tcMask = mask_tc(0,-999,-999,maskspacing,360)

basin = (/"NA","EP","NI","NWP","SH", "Global"/)
nbasin = dimsizes(basin)

do filemonth= 2, 11, 3
  print(filemonth)

  do year = 1970, 2018

    do ens= 1, 19
      if (ens.lt.10) then
        ENSNUM = "0"+ens
      else
        ENSNUM = ens
      end if

      if (filemonth.gt.10) then
        thefile = "../traj_files/trajectories.txt.SMYLE."+year+"."+filemonth+".0"+ENSNUM  ; this is for week 2, use the n-1th fi
      else
        thefile = "../traj_files/trajectories.txt.SMYLE."+year+".0"+filemonth+".0"+ENSNUM  ; this is for week 2, use the n-1th file
      end if

    ncols = 11                    ; assign number of columns
    maxLines = -1
    headerDelimStr = "start"
    delimStr="tab"
    isUnstruc=False
    isHeader=False

    traj_data = getTrajectoriesGeneric(thefile,ncols,maxLines,headerDelimStr,delimStr,isUnstruc,isHeader)
    lon = traj_data(:,2,:)
    lat = traj_data(:,3,:)
    yyyy = traj_data(:,7,:)


; define new trajectory data

   traj_data_new = new((/180,11,180/),float)
   traj_data_new = 0
   traj_data_new!0 = "nstorm"
   traj_data_new!1 = "vars"
   traj_data_new!2 = "nstep"


   dims = dimsizes(lon)
   nstorms = num(.not.ismissing(lat(:,0)))
   print(nstorms)
   icount= 0  ; count for storm number in new traj data

  ; now TC number in each basin
  do ii = 0,nstorms-1
    ibasin  = 999

    orilat=lat(ii,0)
    orilon=min((/lon(ii,0),359.0/))
    tcmask = tcMask({orilat},{orilon})

    if (tcmask.eq.3) then  ; central pacific counts for nwp
      ibasin = 3
    else if (tcmask.eq.5) then ; indian ocean
      ibasin = 2
    else if (tcmask.eq.6.or.tcmask.eq.7) then  ; southern hemisphere
      ibasin = 4
    else
      ibasin  = tcmask-1
    end if
    end if
   end if

     if (ibasin.ge.0.and.ibasin.le.4.and.orilat.ge.-30.and.orilat.le.40.5) then
       traj_data_new(icount,:,:) = traj_data(ii,:,:)
       icount = icount + 1
      else
       print("ibasin = "+ibasin+", mask ="+tcmask+", lat = "+orilat+", lon = "+orilon)
      end if


  end do
  print(icount)

  fout = addfile(thefile+"_trim2.nc", "c")
  fout->traj_data = traj_data_new
  delete(fout)
  delete(dims)
  delete(traj_data)
  delete(traj_data_new)
  delete(lat)
  delete(lon)
  delete(yyyy)

end do
end do

end do



end



