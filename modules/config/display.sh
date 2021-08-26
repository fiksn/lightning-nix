#!/bin/sh

INTERNAL_OUTPUT=$(xrandr | grep connected | cut -d" " -f 1 | head -1)
DISCONNECTED_EXTERNAL=$(xrandr | grep connected | cut -d" " -f 1-2 | tail -n+2 | grep dis | cut -d" " -f 1)
CONNECTED_EXTERNAL=$(xrandr | grep connected | cut -d" " -f 1-2 | tail -n+2 | grep -v dis | cut -d" " -f 1)

echo "Internal $INTERNAL_OUTPUT, disconnected |$DISCONNECTED_EXTERNAL| connected |$CONNECTED_EXTERNAL|"

CHOICES="laptop\nleft\nright\nexternal\nclone"                                                                                                                                                                                                                        
# Your choice in dmenu will determine what xrandr command to run                                                                                                                                                                                               
MENU=$(echo -e $CHOICES | dmenu -i -p "Display config")                                                                                                                                                                                                                          
case "$MENU" in
    laptop)
      STR=""
      for i in $CONNECTED_EXTERNAL; do
        STR="$STR --output $i --off"
      done
      echo xrandr --output $INTERNAL_OUTPUT --auto --primary $STR
      xrandr --output $INTERNAL_OUTPUT --auto --primary $STR
      ;;
    external)
      NUM=$(echo $CONNECTED_EXTERNAL | wc -l)
      if (( $NUM == 1 )); then
        WHICH=$CONNECTED_EXTERNAL
      else
        OTHERS=$(echo $DISCONNECTED_EXTERNAL | tr "\n" " ")
        echo "OTHERS $OTHERS"
        WHICH=$(echo "$CONNECTED_EXTERNAL" | dmenu -i -p "Which monitor - $OTHERS")
        echo "WHICH $WHICH"
      fi
      echo xrandr --output $INTERNAL_OUTPUT --off --output $WHICH --auto --primary 
      xrandr --output $INTERNAL_OUTPUT --off --output $WHICH --auto --primary 
      ;;
    clone)
      STR=""
      for i in $CONNECTED_EXTERNAL; do
        STR="$STR --output $i --auto --same-as $INTERNAL_OUTPUT"
      done

      echo xrandr --output $INTERNAL_OUTPUT --auto $STR
      xrandr --output $INTERNAL_OUTPUT --auto $STR
      ;;

    left)
      NUM=$(echo $CONNECTED_EXTERNAL | wc -l)
      if (( $NUM == 1 )); then
        WHICH=$CONNECTED_EXTERNAL
      else
        OTHERS=$(echo $DISCONNECTED_EXTERNAL | tr "\n" " ")
        echo "OTHERS $OTHERS"
        WHICH=$(echo "$CONNECTED_EXTERNAL" | dmenu -i -p "Which monitor - $OTHERS")
        echo "WHICH $WHICH"
      fi
      echo xrandr --output $INTERNAL_OUTPUT --auto --output $WHICH --auto --left-of $INTERNAL_OUTPUT --primary
      xrandr --output $INTERNAL_OUTPUT --auto --output $WHICH --auto --left-of $INTERNAL_OUTPUT --primary
      ;;
    right) 
      NUM=$(echo $CONNECTED_EXTERNAL | wc -l)
      if (( $NUM == 1 )); then
        WHICH=$CONNECTED_EXTERNAL
      else
        OTHERS=$(echo $DISCONNECTED_EXTERNAL | tr "\n" " ")
        echo "OTHERS $OTHERS"
        WHICH=$(echo "$CONNECTED_EXTERNAL" | dmenu -i -p "Which monitor - $OTHERS")
        echo "WHICH $WHICH"
      fi
      echo xrandr --output $INTERNAL_OUTPUT --auto --output $WHICH --auto --right-of $INTERNAL_OUTPUT --primary
      xrandr --output $INTERNAL_OUTPUT --auto --output $WHICH --auto --right-of $INTERNAL_OUTPUT --primary
      ;;
esac
