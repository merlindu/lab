%year=year
%month=month
%day=day
%import icatch_playback
		%files_list = icatch_playback.query_files_by_date( year, month, day )
		%total = files_list[0]
		%items = files_list[1]
		%row=total/4
		%column=total%4
		%i=0
		%j=0
		%while i<row:
			<div class="container">
				<div class="row">
					%for k in range(1,5):
						<div class="col-sm-6 col-md-3">
						%cur=4*i+k
						<div href="#" class="thumbnail">
							%video_name = str(items[cur-1][0])
							%path = str(items[cur-1][1])
							%video_file = path + '/' + video_name
							%date = str(items[cur-1][2])
							%thumbnail_url = "/images/"+ str(items[cur-1][3])
							<a onclick="show_play_frame( this.id, '{{video_file}}' );" id="id_a_{{cur}}"><img src="{{thumbnail_url}}" alt="Video load failed..."/></a>
							<table style="width:100%">
								<tr>
									<td>
										<div style="word-break:break-all; word-wrap:break-word;">{{video_name}}</div>
									</td>
								</tr>
								<tr>
									<td> 
										<div style="word-break:break-all; word-wrap:break-word;">{{date}}</div>
									</td>
								</tr>
							</table>
				    	</div>
			   		</div>
					%end
				</div>
			</div>
			%i=i+1
			%end
			<div class="container">
				<div class="row">
					%for j in range(0,column):
					<div class="col-sm-6 col-md-3">
						%cur=4*row+j+1
						<div href="#" class="thumbnail">
							%video_name = str(items[cur-1][0])
							%path = str(items[cur-1][1])
							%video_file = path + '/' + video_name
							%date = str(items[cur-1][2])
							%thumbnail_url = "/images/"+ str(items[cur-1][3])
							<a onclick="show_play_frame( this.id, '{{video_file}}' );" id="id_a_{{cur}}"><img src="{{thumbnail_url}}" alt="Video load failed..."/></a>
							<table style="width:100%">
								<tr>
									<td>
										<div style="word-break:break-all; word-wrap:break-word;">{{video_name}}</div>
									</td>
								</tr>
								<tr>
									<td> 
										<div style="word-break:break-all; word-wrap:break-word;">{{date}}</div>
									</td>
								</tr>
							</table>
				    	</div>
			   		</div>
					%end
				</div>
			</div>
