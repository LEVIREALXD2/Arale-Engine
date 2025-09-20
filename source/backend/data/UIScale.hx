package backend.data;

class UIScale
{
    static public function adjust(data:Float, flip:Bool = false):Float {
        return flip ? data / ClientPrefs.data.uiScale : data * ClientPrefs.data.uiScale;
    }
}	