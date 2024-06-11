package firebrick;

import ase.chunks.TagsChunk;
import Raylib.Colors;
import Raylib.Vector2;
import haxe.ds.Vector;
import Raylib.Rectangle;
import Raylib.Image;
import cpp.NativeArray;
import cpp.Pointer;
import haxe.io.Bytes;
import ase.Frame;
import Raylib.Texture;
import sys.io.File;
import ase.Ase;

typedef AsepriteLayer = {
    texture:Texture,
    layerID:Int,
    frameID:Int
}

@:structInit
class Tag {
  public var name(default, null):String;
  public var startFrame(default, null):Int;
  public var endFrame(default, null):Int;
  public var animationDirection(default, null):Int;

  public static function fromChunk(chunk:ase.chunks.TagsChunk.Tag):Tag {
    return {
      name: chunk.tagName,
      startFrame: chunk.fromFrame,
      endFrame: chunk.toFrame,
      animationDirection: chunk.animDirection
    }
  }
}

class Aseprite {
    public var ase:Ase;
    public var width:Int;
    public var height:Int;

    public var intermediateLayers:Array<AsepriteLayer> = [];
    public var intermediateFrames:Map<Int, Texture> = [];
    public var spritesheet:Texture;

    public var tags:Map<String, Tag> = [];
    public var duration:Map<Int, Float> = [];

    public function new(file:String) {
        ase = Ase.fromBytes(File.getBytes(file));
        width = ase.width;
        height = ase.width;

        for(frame in 0...ase.frames.length) {
            var aseFrame = ase.frames[frame];
            for(layer in 0...ase.layers.length) {
                intermediateLayers.push({
                    texture: genTexture(layer, aseFrame),
                    layerID: layer,
                    frameID: frame
                });
            }
        }

        for(frame in 0...ase.frames.length) {
            var renderTarget = Raylib.loadRenderTexture(ase.width, ase.height);

            for(layer in intermediateLayers) {
                if(layer.frameID == frame) {
                    var sourceRec = Rectangle.create(0, 0, ase.frames[frame].cel(layer.layerID).width, ase.frames[frame].cel(layer.layerID).height);
                
                    Raylib.beginTextureMode(renderTarget);
                    Raylib.drawTexturePro(layer.texture, sourceRec, Raylib.Rectangle.create(ase.frames[frame].cel(layer.layerID).xPosition, ase.frames[frame].cel(layer.layerID).yPosition, ase.frames[frame].cel(layer.layerID).width, ase.frames[frame].cel(layer.layerID).height), Vector2.zero(), 0, Colors.WHITE);
                    Raylib.endTextureMode();
                }

                var image:Raylib.RlImage = Raylib.loadImageFromTexture(renderTarget.texture);
                Raylib.imageFlipVertical(cast image);
                var texture = Raylib.loadTextureFromImage(image);
                intermediateFrames.set(frame, texture);
                Raylib.unloadRenderTexture(renderTarget);
            }
        }

        var spritesheetTexture = Raylib.loadRenderTexture(ase.width * ase.frames.length, ase.height);
        var index = 0;
        for(frame in 0...ase.frames.length) {
            var f = intermediateFrames[frame];

            Raylib.beginTextureMode(spritesheetTexture);
            Raylib.drawTexture(f, 0 + (f.width * index), 0, Colors.WHITE);
            Raylib.endTextureMode();
            index++;
        }

        var image:Raylib.RlImage = Raylib.loadImageFromTexture(spritesheetTexture.texture);
        Raylib.imageFlipVertical(cast image);
        spritesheet = Raylib.loadTextureFromImage(image);
        Raylib.unloadRenderTexture(spritesheetTexture);

        for(i in intermediateFrames) {
            Raylib.unloadTexture(i);
        }
        intermediateFrames.clear();

        for(i in intermediateLayers) {
            Raylib.unloadTexture(i.texture);
            intermediateLayers.remove(i);
        }

        for(frame in ase.frames) {
            for(chunk in frame.chunks) {
                switch (chunk.header.type) {
                    case TAGS:
                        var frameTags:TagsChunk = cast chunk;

                        for(frameTagData in frameTags.tags) {
                            var animationTag = Tag.fromChunk(frameTagData);

                            if(tags.exists(frameTagData.tagName)) {
                                throw 'ERROR: This file already contains a tag named ${frameTagData.tagName}';
                            } else  {
                                tags[frameTagData.tagName] = animationTag;
                            }
                        }
                    case _:
                }
            }

            duration[ase.frames.indexOf(frame)] = frame.duration;
        }
    }

    public function genTexture(layer:Int, frame:Frame):Texture {
        var layerIndex:Int = layer;
        var celWidth:Int = frame.cel(layer).width;
        var celHeight:Int = frame.cel(layer).height;
        var celPixelData:Bytes = frame.cel(layerIndex).pixelData;
        var celDataPointer:Pointer<cpp.Void> = NativeArray.address(celPixelData.getData(), 0).reinterpret();
        var celImage = Image.create(celDataPointer.raw, celWidth, celHeight, 1, Raylib.PixelFormat.UNCOMPRESSED_R8G8B8A8);
        return Raylib.loadTextureFromImage(celImage);
    }

    public function unload() {
        Raylib.unloadTexture(spritesheet);
    }
}